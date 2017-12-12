; RUN: llc < %s -mtriple=x86_64-apple-darwin8 -mcpu=skylake | FileCheck %s -check-prefix=DARWIN

; DARWIN-LABEL _gc_livevar

; DARWIN: 	callq	_foo1
; DARWIN-NEXT: [[LABEL1:.*]]:

; DARWIN: 	callq	_foo2
; DARWIN-NEXT: [[LABEL2:.*]]:

; DARWIN: .section	__LLVM_STACKMAPS,__llvm_stackmaps
; DARWIN-NEXT: __LLVM_StackMaps:
; DARWIN: .long [[LABEL1]]-_gc_livevar
; DARWIN: .long [[LABEL2]]-_gc_livevar

define i32 @gc_livevar(i8 addrspace(1)* %v1) gc "statepoint-example" personality i32 (...)* @__qlang_personality_v0 {
entry:
  %0 = call i32 @foo1() [ "gc-livevars"(i8 addrspace(1)* %v1) ]

  %1 = invoke i32 @foo2() [ "gc-livevars"(i8 addrspace(1)* %v1) ]
          to label %cont1 unwind label %unwnd

cont1:                                            ; preds = %entry
  ret i32 0

unwnd:                                            ; preds = %entry
  %l = landingpad { i8*, i32 }
          cleanup
  ret i32 0
}

declare i32 @foo1()
declare i32 @foo2()
declare i32 @__qlang_personality_v0(...)
