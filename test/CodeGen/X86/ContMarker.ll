; RUN: llc < %s -mtriple=i686-apple-darwin8 -mcpu=yonah | FileCheck %s -check-prefix=DARWIN

; DARWIN: 	movl	$[[STEALB:Ltmp[0-9]+]], (%esp)
; DARWIN-NEXT: 	calll	_callee

; DARWIN: 	movl	%eax, (%esp)
; DARWIN-NEXT: 	calll	_dummy1
; DARWIN-NEXT: 	movl	$1, %eax
; DARWIN-NEXT: 	addl	$12, %esp
; DARWIN-NEXT: 	retl

; DARWIN: [[STEALB]]:
; DARWIN-NEXT: 	nop
; DARWIN-NEXT: 	movl	%eax, (%esp)
; DARWIN-NEXT: 	calll	_dummy2
; DARWIN-NEXT: 	movl	$2, %eax
; DARWIN-NEXT: 	addl	$12, %esp
; DARWIN-NEXT: 	retl

define i32 @test0() personality i32 (...)* @__qlang_personality_v0 {
entry:
  %v = invoke i32 @callee(i8* blockaddress(@test0, %t2)) to label %cont1 unwind label %unwnd

unwnd:
  %l = landingpad {i8*, i32} cleanup
  ret i32 4
  
cont1:
  %c = call i1 @llvm.cont_marker()
  br i1 %c, label %t1, label %t2
 
t1:
  call void @dummy1(i32 %v)
  br label %r

t2:
  %v2 = call i32 @llvm.cont_value.i32()
  call void @dummy2(i32 %v2)
  br label %r

r:
  %a = phi i32 [1,  %t1], [2, %t2]
  ret i32 %a
}

declare i32 @callee(i8*)
declare void @dummy1(i32)
declare void @dummy2(i32)
declare i1 @llvm.cont_marker()
declare i32 @llvm.cont_value.i32()
declare i32 @__qlang_personality_v0(...)
