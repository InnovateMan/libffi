//
//  ViewController.m
//  TestLibffi
//
//  Created by ws on 2020/5/15.
//

#import "ViewController.h"
#import <ffi.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <os/lock.h>


@interface ViewController ()

@end

@implementation ViewController 

int invokeFunc1(int a, int b) {
    return a + b;
}

void define_func(ffi_cif *cif, char **ret, int **args, void *userdata) {
    
    int value = *args[0];
    int value1 = *args[1];
    //8.
    *ret = [[NSString stringWithFormat:@"str-%d", (value + value1)] UTF8String];
}



- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self defineFunc];
}

- (void)invokeFunc {
    //1.
   ffi_type **argTypes;
   argTypes = malloc(sizeof(ffi_type *) * 2);
   argTypes[0] = &ffi_type_sint;
   argTypes[1] = &ffi_type_sint;
   //2.
   ffi_type *retType = &ffi_type_sint;
   //3.
   ffi_cif cif;
   ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 2, retType, argTypes);
   //4.
   void **args = malloc(sizeof(void *) * 2);
   int x = 1, y = 2;
   args[0] = &x;
   args[1] = &y;
   int ret;
   //5.
   ffi_call(&cif, (void(*)(void))invokeFunc1, &ret, args);
   NSLog(@"libffi return value: %d", ret);
}

- (void)defineFunc {
    //1.
    ffi_type **argTypes;
    ffi_type *returnTypes;
    
    argTypes = malloc(sizeof(ffi_type *) * 2);
    argTypes[0] = &ffi_type_sint;
    argTypes[1] = &ffi_type_sint;
    
    returnTypes = malloc(sizeof(ffi_type *));
    returnTypes = &ffi_type_pointer;
    
    ffi_cif *cif = malloc(sizeof(ffi_cif));
    ffi_status status = ffi_prep_cif(cif, FFI_DEFAULT_ABI, 2, returnTypes, argTypes);
    if (status != FFI_OK) {
        NSLog(@"ffi_prep_cif return %u", status);
        return;
    }
    //2.
    char* (*funcInvoke)(int, int);
    //3.
    ffi_closure *closure = ffi_closure_alloc(sizeof(ffi_closure), &funcInvoke);
    //4.
    status = ffi_prep_closure_loc(closure, cif, define_func, (__bridge void *)self, funcInvoke);
    if (status != FFI_OK) {
        NSLog(@"ffi_prep_closure_loc return %u", status);
        return;
    }
    //5.
    char *result = funcInvoke(2, 3);
    NSLog(@"libffi return func value: %@", [NSString stringWithUTF8String:result]);
    ffi_closure_free(closure);

}

@end
