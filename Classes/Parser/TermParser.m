//
//  TermParser.m
//  TouchAlgebra
//
//  Created by David Sullivan on 5/28/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TermParser.h"
#import "Term.h"
#import "Integer.h"
#import "Constant.h"
#import "Variable.h"		
#import "Multiplication.h"
#import "Addition.h"
#import "Power.h"
#import "Fraction.h"
#import "Equation.h"

#define TEMP_FILE_NAME @"tempFile.txt"
#define MAX_ERROR_MSG_LENGTH 100

extern int  yyparse();
extern FILE *yyin;

enum treetype {operator_node, number_node, variable_node};

typedef struct tree {
	enum treetype nodetype;
	union {
		struct {struct tree *left, *right; char operator;} an_operator;
		int a_number;
		char a_variable;
	} body;
} tree;

// global variables for communicating with the grammar code
// don't use more than one parser at a time!
static tree *inputTree;
static char cErrorMessage[MAX_ERROR_MSG_LENGTH];
static BOOL errorRaised = NO;

void myErrorFunction (const char *err);
void setTree(tree *t);


void myErrorFunction (const char *err){
	
	errorRaised = YES;
	strncpy(cErrorMessage, err, strlen(err));
	
}

void setTree(tree *t){
	
	inputTree = t;
	
}

@implementation TermParser

@synthesize errorMessage;

- (Term *) buildTerm: (tree *) t{
	
	if (t) {
		
		int type = t->nodetype;
		
		if (type == operator_node) {
			
			char op = t->body.an_operator.operator;
			
			if (op == '=') {
				
				Term *lhs = [self buildTerm:t->body.an_operator.left];
				Term *rhs = [self buildTerm:t->body.an_operator.right];
				free(t); 
				return [[[Equation alloc] initWithLHS:lhs andRHS:rhs] autorelease];
			}
			else if (op == '*') {
				
				Term *lhs = [self buildTerm:t->body.an_operator.left];
				Term *rhs = [self buildTerm:t->body.an_operator.right];
				free(t); 
				return [[[Multiplication alloc] init:lhs, rhs, nil] autorelease];
			}
			else if (op == '/') {
				
				Term *num = [self buildTerm:t->body.an_operator.left];
				Term *denom = [self buildTerm:t->body.an_operator.right];
				free(t); 
				return [[[Fraction alloc] initWithNum:num andDenom:denom] autorelease];
			}
			else if (op == '+') {
				
				Term *lhs = [self buildTerm:t->body.an_operator.left];
				Term *rhs = [self buildTerm:t->body.an_operator.right];
				free(t); 
				return [[[Addition alloc] init:lhs, rhs, nil] autorelease];
			}
			else if (op == '-') {
				
				Term *lhs = [self buildTerm:t->body.an_operator.left];
				Term *rhs = [self buildTerm:t->body.an_operator.right];
				Addition *a = [[[Addition alloc] init:lhs, nil] autorelease];
				[a appendTerm:rhs Operator: SUBTRACTION_OPERATOR];
				free(t); 
				return a;
			}
			else if (op == '^') {
				
				Term *base = [self buildTerm:t->body.an_operator.left];
				Term *exp = [self buildTerm:t->body.an_operator.right];
				free(t); 
				return [[[Power alloc] initWithBase:base andExponent:exp] autorelease];
			}
			
			// ~ used for unary minus
			else if (op == '~') {
				
				Term *term = [self buildTerm:t->body.an_operator.right];

				// if integer return negative value
				if ([term isKindOfClass:[Integer class]]) {

					free(t); 
					int val = [(Integer *) term rawValue];
                    
                    // check for min/max size
                    if (val > MAX_INTEGER || val < -MAX_INTEGER) {
                        errorRaised = YES;
                        [self setErrorMessage:@"Number is too big or too small"];
                        return nil;
                    }
                    else {
                        return [[[Integer alloc] initWithInt:val*-1] autorelease];
                    }
				}
				
				// otherwise take the oppostie of the term
				else {
					free(t); 
					[term opposite];
					return term;
				}
			}
		}
		
		else if (type == number_node) {
			Integer *i = [[[Integer alloc] initWithInt:t->body.a_number] autorelease];
			free(t); 
            // check for min/max size
            if ([i rawValue] > MAX_INTEGER || [i rawValue] < -MAX_INTEGER) {
                errorRaised = YES;
                [self setErrorMessage:@"Number is too big or too small"];
                return nil;
            }
            else {
                return i;
            }

		}

		else if (type == variable_node) {
			
			// convert character to string
			char c = t->body.a_variable;
			char carray[5];
			sprintf(carray, "%c", c);
			NSString *s = [NSString stringWithCString:carray encoding:NSASCIIStringEncoding];
			
			if (c == 'x' || c == 'X' ||
				c == 'y' || c == 'Y' ||
				c == 'z' || c == 'Z') {
				
				free(t); 
				return [[[Variable alloc] initWithTermValue:s] autorelease];
			}
			else {
				free(t); 
				return [[[Constant alloc] initWithTermValue:s] autorelease];
			}
		}		
	}

	return nil;
}

- (Term *) parseTerm: (NSString *) s {
	
	// clear error message
	if (errorMessage || errorRaised) {
		[self setErrorMessage:nil];
		errorRaised = NO;
	}
	
	//get the documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	// file name in documents directory
	NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, TEMP_FILE_NAME];
	const char *fileName = [fullPath cStringUsingEncoding:NSASCIIStringEncoding];

	// write the string to file
	FILE *fp=fopen(fileName,"w");
	if (fp) {
		fputs([s cStringUsingEncoding:NSASCIIStringEncoding], fp);
		fputs(";", fp);	// add the terminal character
		fclose(fp);
	}
	else {
		errorRaised = YES;
		[self setErrorMessage:@"Unable to open parse file for writing"];
		return nil;
	}
	
	// open file and parse
	fp=fopen(fileName,"r");
	if (fp) {
		yyin = fp;
		yyparse();
		fclose(fp);
	}
	else {
		errorRaised = YES;
		[self setErrorMessage:@"Unable to open parse file for reading"];
		return nil;
	}
		
	// error? 
	if (errorRaised) {
		
		[self setErrorMessage:[NSString stringWithCString:cErrorMessage encoding:NSASCIIStringEncoding]];
		
		// TODO: resetting the parse state should be done in the YACC grammar

		fclose(fp);

		// truncate the input file
		fp=fopen(fileName,"w");
		fputs("\n", fp);	// add the terminal character
		fclose(fp);
		
		// parse the empty file to clear the error state
		fp=fopen(fileName,"r");
		yyin = fp;
		yyparse();
		fclose(fp);
		return nil;
	}
	else if (inputTree) {

		// catch any exceptions building the term
		@try {
			
			return [self buildTerm:inputTree];
		}
		@catch (NSException * e) {

			[self setErrorMessage:[e reason]];
		}
	}
	return nil;
}

- (BOOL) parseError {
	
	return errorMessage != nil;
}

- (void) dealloc {
	
	if (errorMessage) {
		[errorMessage release];
	}
	[super dealloc];
}

@end
