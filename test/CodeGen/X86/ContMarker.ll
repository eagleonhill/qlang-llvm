; RUN: llc < %s -mtriple=i686-apple-darwin8 -mcpu=yonah | FileCheck %s -check-prefix=DARWIN

; DARWIN-LABEL _test_int:
; DARWIN: 	calll	_callee

; DARWIN: 	movl	%eax, (%esp)
; DARWIN-NEXT: 	calll	_dummy1
; DARWIN-NEXT: 	movl	$1, %eax
; DARWIN-NEXT: 	addl	$12, %esp
; DARWIN-NEXT: 	retl

; DARWIN: 	nop
; DARWIN-NEXT: 	movl	%eax, (%esp)
; DARWIN-NEXT: 	calll	_dummy2
; DARWIN-NEXT: 	movl	$2, %eax
; DARWIN-NEXT: 	addl	$12, %esp
; DARWIN-NEXT: 	retl

define i32 @test_int() personality i32 (...)* @__qlang_personality_v0 {
entry:
  %vtoken = invoke token(i8*, i32()*, ...) @llvm.cont_invoke.p0f_i32f(i8* blockaddress(@test_int, %t2), i32()* @callee) to label %cont1 unwind label %unwnd

unwnd:
  %l = landingpad {i8*, i32} cleanup
  ret i32 4
  
cont1:
  %c = call i1 @llvm.cont_marker(token %vtoken)
  br i1 %c, label %t1, label %t2
 
t1:
  %v = call i32 @llvm.cont_orig_value.i32(token %vtoken)
  call void @dummy1(i32 %v)
  br label %r

t2:
  %v2 = call i32 @llvm.cont_branch_value.i32(token %vtoken)
  call void @dummy2(i32 %v2)
  br label %r

r:
  %a = phi i32 [1,  %t1], [2, %t2]
  ret i32 %a
}

; DARWIN-LABEL _test_ptrs:
; DARWIN: 	calll	_callee_str

; DARWIN: 	movl	[[RETP:[^,]+]], [[TMP1:[^,]+]]
; DARWIN-NEXT:  movl  [[TMP1]], (%esp)
; DARWIN-NEXT: 	calll	_dummy1
; DARWIN-NEXT: 	movl	$1, %eax
; DARWIN-NEXT: 	addl	$[[StackSize:[0-9]+]], %esp
; DARWIN-NEXT: 	retl

; DARWIN: 	nop
; DARWIN-NEXT: 	movl	[[RETP]], [[TMP2:[^,]+]]
; DARWIN-NEXT:  movl  [[TMP2]], (%esp)
; DARWIN-NEXT: 	calll	_dummy2
; DARWIN-NEXT: 	movl	$2, %eax
; DARWIN-NEXT: 	addl	$[[StackSize]], %esp
; DARWIN-NEXT: 	retl

%struct.ptrs = type {i32*, i32*, i32, i32*, i32*}

define i32 @test_ptrs() personality i32 (...)* @__qlang_personality_v0 {
entry:
  %vtoken = invoke token(i8*, %struct.ptrs()*, ...) @llvm.cont_invoke.p0f_s_struct.ptrssf(i8* blockaddress(@test_ptrs, %t2), %struct.ptrs ()* @callee_str) to label %cont1 unwind label %unwnd

unwnd:
  %l = landingpad {i8*, i32} cleanup
  ret i32 4
  
cont1:
  %c = call i1 @llvm.cont_marker(token %vtoken)
  br i1 %c, label %t1, label %t2
 
t1:
  %v = call %struct.ptrs @llvm.cont_orig_value.s_struct.ptrss(token %vtoken)
  %v1 = extractvalue %struct.ptrs %v, 2
  call void @dummy1(i32 %v1)
  br label %r

t2:
  %v2 = call %struct.ptrs @llvm.cont_branch_value.s_struct.ptrss(token %vtoken)
  %v3 = extractvalue %struct.ptrs %v2, 2
  call void @dummy2(i32 %v3)
  br label %r

r:
  %a = phi i32 [1,  %t1], [2, %t2]
  ret i32 %a
}

declare i32 @callee()
declare %struct.ptrs @callee_str()
declare void @dummy1(i32)
declare void @dummy2(i32)
declare token @llvm.cont_invoke.p0f_i32f(i8*, i32()*, ...)
declare token @llvm.cont_invoke.p0f_s_struct.ptrssf(i8*, %struct.ptrs()*, ...)
declare i1 @llvm.cont_marker(token)
declare i32 @llvm.cont_orig_value.i32(token)
declare i32 @llvm.cont_branch_value.i32(token)
declare %struct.ptrs @llvm.cont_orig_value.s_struct.ptrss(token)
declare %struct.ptrs @llvm.cont_branch_value.s_struct.ptrss(token)
declare i32 @__qlang_personality_v0(...)
