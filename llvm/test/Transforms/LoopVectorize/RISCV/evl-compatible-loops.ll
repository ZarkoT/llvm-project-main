; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 4
; RUN: opt -passes=loop-vectorize -force-tail-folding-style=data-with-evl \
; RUN: -prefer-predicate-over-epilogue=predicate-dont-vectorize \
; RUN: -mtriple=riscv64 -mattr=+v -S < %s | FileCheck %s

; Make sure we do not vectorize a loop with a widened int induction.
define void @test_wide_integer_induction(ptr noalias %a, i64 %N) {
; CHECK-LABEL: define void @test_wide_integer_induction(
; CHECK-SAME: ptr noalias [[A:%.*]], i64 [[N:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = sub i64 -1, [[N]]
; CHECK-NEXT:    [[TMP1:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP2:%.*]] = mul i64 [[TMP1]], 2
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ult i64 [[TMP0]], [[TMP2]]
; CHECK-NEXT:    br i1 [[TMP3]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[TMP4:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP5:%.*]] = mul i64 [[TMP4]], 2
; CHECK-NEXT:    [[TMP6:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP7:%.*]] = mul i64 [[TMP6]], 2
; CHECK-NEXT:    [[TMP8:%.*]] = sub i64 [[TMP7]], 1
; CHECK-NEXT:    [[N_RND_UP:%.*]] = add i64 [[N]], [[TMP8]]
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[N_RND_UP]], [[TMP5]]
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[N_RND_UP]], [[N_MOD_VF]]
; CHECK-NEXT:    [[TMP9:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP10:%.*]] = mul i64 [[TMP9]], 2
; CHECK-NEXT:    [[TMP11:%.*]] = call <vscale x 2 x i64> @llvm.experimental.stepvector.nxv2i64()
; CHECK-NEXT:    [[TMP12:%.*]] = add <vscale x 2 x i64> [[TMP11]], zeroinitializer
; CHECK-NEXT:    [[TMP13:%.*]] = mul <vscale x 2 x i64> [[TMP12]], shufflevector (<vscale x 2 x i64> insertelement (<vscale x 2 x i64> poison, i64 1, i64 0), <vscale x 2 x i64> poison, <vscale x 2 x i32> zeroinitializer)
; CHECK-NEXT:    [[INDUCTION:%.*]] = add <vscale x 2 x i64> zeroinitializer, [[TMP13]]
; CHECK-NEXT:    [[TMP14:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP15:%.*]] = mul i64 [[TMP14]], 2
; CHECK-NEXT:    [[TMP16:%.*]] = mul i64 1, [[TMP15]]
; CHECK-NEXT:    [[DOTSPLATINSERT:%.*]] = insertelement <vscale x 2 x i64> poison, i64 [[TMP16]], i64 0
; CHECK-NEXT:    [[DOTSPLAT:%.*]] = shufflevector <vscale x 2 x i64> [[DOTSPLATINSERT]], <vscale x 2 x i64> poison, <vscale x 2 x i32> zeroinitializer
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[EVL_BASED_IV:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_EVL_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_IND:%.*]] = phi <vscale x 2 x i64> [ [[INDUCTION]], [[VECTOR_PH]] ], [ [[VEC_IND_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP17:%.*]] = sub i64 [[N]], [[EVL_BASED_IV]]
; CHECK-NEXT:    [[TMP18:%.*]] = call i32 @llvm.experimental.get.vector.length.i64(i64 [[TMP17]], i32 2, i1 true)
; CHECK-NEXT:    [[TMP19:%.*]] = add i64 [[EVL_BASED_IV]], 0
; CHECK-NEXT:    [[TMP20:%.*]] = getelementptr inbounds i64, ptr [[A]], i64 [[TMP19]]
; CHECK-NEXT:    [[TMP21:%.*]] = getelementptr inbounds i64, ptr [[TMP20]], i32 0
; CHECK-NEXT:    call void @llvm.vp.store.nxv2i64.p0(<vscale x 2 x i64> [[VEC_IND]], ptr align 8 [[TMP21]], <vscale x 2 x i1> shufflevector (<vscale x 2 x i1> insertelement (<vscale x 2 x i1> poison, i1 true, i64 0), <vscale x 2 x i1> poison, <vscale x 2 x i32> zeroinitializer), i32 [[TMP18]])
; CHECK-NEXT:    [[TMP22:%.*]] = zext i32 [[TMP18]] to i64
; CHECK-NEXT:    [[INDEX_EVL_NEXT]] = add i64 [[TMP22]], [[EVL_BASED_IV]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], [[TMP10]]
; CHECK-NEXT:    [[VEC_IND_NEXT]] = add <vscale x 2 x i64> [[VEC_IND]], [[DOTSPLAT]]
; CHECK-NEXT:    [[TMP23:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP23]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    br i1 true, label [[FOR_COND_CLEANUP:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[IV_NEXT:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i64, ptr [[A]], i64 [[IV]]
; CHECK-NEXT:    store i64 [[IV]], ptr [[ARRAYIDX]], align 8
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[IV_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND_NOT]], label [[FOR_COND_CLEANUP]], label [[FOR_BODY]], !llvm.loop [[LOOP3:![0-9]+]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.body

for.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i64, ptr %a, i64 %iv
  store i64 %iv, ptr %arrayidx, align 8
  %iv.next = add nuw nsw i64 %iv, 1
  %exitcond.not = icmp eq i64 %iv.next, %N
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body

for.cond.cleanup:
  ret void
}

; Make sure we do not vectorize a loop with a widened ptr induction.
define void @test_wide_ptr_induction(ptr noalias %a, ptr noalias %b, i64 %N) {
; CHECK-LABEL: define void @test_wide_ptr_induction(
; CHECK-SAME: ptr noalias [[A:%.*]], ptr noalias [[B:%.*]], i64 [[N:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = sub i64 -1, [[N]]
; CHECK-NEXT:    [[TMP1:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP2:%.*]] = mul i64 [[TMP1]], 2
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ult i64 [[TMP0]], [[TMP2]]
; CHECK-NEXT:    br i1 [[TMP3]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[TMP4:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP5:%.*]] = mul i64 [[TMP4]], 2
; CHECK-NEXT:    [[TMP6:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP7:%.*]] = mul i64 [[TMP6]], 2
; CHECK-NEXT:    [[TMP8:%.*]] = sub i64 [[TMP7]], 1
; CHECK-NEXT:    [[N_RND_UP:%.*]] = add i64 [[N]], [[TMP8]]
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[N_RND_UP]], [[TMP5]]
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[N_RND_UP]], [[N_MOD_VF]]
; CHECK-NEXT:    [[TMP9:%.*]] = mul i64 [[N_VEC]], 8
; CHECK-NEXT:    [[IND_END:%.*]] = getelementptr i8, ptr [[B]], i64 [[TMP9]]
; CHECK-NEXT:    [[TMP10:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP11:%.*]] = mul i64 [[TMP10]], 2
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[POINTER_PHI:%.*]] = phi ptr [ [[B]], [[VECTOR_PH]] ], [ [[PTR_IND:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[EVL_BASED_IV:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_EVL_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP12:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP13:%.*]] = mul i64 [[TMP12]], 2
; CHECK-NEXT:    [[TMP14:%.*]] = mul i64 [[TMP13]], 1
; CHECK-NEXT:    [[TMP15:%.*]] = mul i64 8, [[TMP14]]
; CHECK-NEXT:    [[TMP16:%.*]] = mul i64 [[TMP13]], 0
; CHECK-NEXT:    [[DOTSPLATINSERT:%.*]] = insertelement <vscale x 2 x i64> poison, i64 [[TMP16]], i64 0
; CHECK-NEXT:    [[DOTSPLAT:%.*]] = shufflevector <vscale x 2 x i64> [[DOTSPLATINSERT]], <vscale x 2 x i64> poison, <vscale x 2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP17:%.*]] = call <vscale x 2 x i64> @llvm.experimental.stepvector.nxv2i64()
; CHECK-NEXT:    [[TMP18:%.*]] = add <vscale x 2 x i64> [[DOTSPLAT]], [[TMP17]]
; CHECK-NEXT:    [[VECTOR_GEP:%.*]] = mul <vscale x 2 x i64> [[TMP18]], shufflevector (<vscale x 2 x i64> insertelement (<vscale x 2 x i64> poison, i64 8, i64 0), <vscale x 2 x i64> poison, <vscale x 2 x i32> zeroinitializer)
; CHECK-NEXT:    [[TMP19:%.*]] = getelementptr i8, ptr [[POINTER_PHI]], <vscale x 2 x i64> [[VECTOR_GEP]]
; CHECK-NEXT:    [[TMP20:%.*]] = sub i64 [[N]], [[EVL_BASED_IV]]
; CHECK-NEXT:    [[TMP21:%.*]] = call i32 @llvm.experimental.get.vector.length.i64(i64 [[TMP20]], i32 2, i1 true)
; CHECK-NEXT:    [[TMP22:%.*]] = add i64 [[EVL_BASED_IV]], 0
; CHECK-NEXT:    [[TMP23:%.*]] = getelementptr inbounds i64, ptr [[A]], i64 [[TMP22]]
; CHECK-NEXT:    [[TMP24:%.*]] = getelementptr inbounds ptr, ptr [[TMP23]], i32 0
; CHECK-NEXT:    call void @llvm.vp.store.nxv2p0.p0(<vscale x 2 x ptr> [[TMP19]], ptr align 8 [[TMP24]], <vscale x 2 x i1> shufflevector (<vscale x 2 x i1> insertelement (<vscale x 2 x i1> poison, i1 true, i64 0), <vscale x 2 x i1> poison, <vscale x 2 x i32> zeroinitializer), i32 [[TMP21]])
; CHECK-NEXT:    [[TMP25:%.*]] = zext i32 [[TMP21]] to i64
; CHECK-NEXT:    [[INDEX_EVL_NEXT]] = add i64 [[TMP25]], [[EVL_BASED_IV]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], [[TMP11]]
; CHECK-NEXT:    [[PTR_IND]] = getelementptr i8, ptr [[POINTER_PHI]], i64 [[TMP15]]
; CHECK-NEXT:    [[TMP26:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP26]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP4:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    br i1 true, label [[FOR_COND_CLEANUP:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[BC_RESUME_VAL1:%.*]] = phi ptr [ [[IND_END]], [[MIDDLE_BLOCK]] ], [ [[B]], [[ENTRY]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[IV_NEXT:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[ADDR:%.*]] = phi ptr [ [[INCDEC_PTR:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL1]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[INCDEC_PTR]] = getelementptr inbounds i8, ptr [[ADDR]], i64 8
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i64, ptr [[A]], i64 [[IV]]
; CHECK-NEXT:    store ptr [[ADDR]], ptr [[ARRAYIDX]], align 8
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[IV_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND_NOT]], label [[FOR_COND_CLEANUP]], label [[FOR_BODY]], !llvm.loop [[LOOP5:![0-9]+]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.body

for.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %addr = phi ptr [ %incdec.ptr, %for.body ], [ %b, %entry ]
  %incdec.ptr = getelementptr inbounds i8, ptr %addr, i64 8
  %arrayidx = getelementptr inbounds i64, ptr %a, i64 %iv
  store ptr %addr, ptr %arrayidx, align 8
  %iv.next = add nuw nsw i64 %iv, 1
  %exitcond.not = icmp eq i64 %iv.next, %N
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body

for.cond.cleanup:
  ret void
}
;.
; CHECK: [[LOOP0]] = distinct !{[[LOOP0]], [[META1:![0-9]+]], [[META2:![0-9]+]]}
; CHECK: [[META1]] = !{!"llvm.loop.isvectorized", i32 1}
; CHECK: [[META2]] = !{!"llvm.loop.unroll.runtime.disable"}
; CHECK: [[LOOP3]] = distinct !{[[LOOP3]], [[META2]], [[META1]]}
; CHECK: [[LOOP4]] = distinct !{[[LOOP4]], [[META1]], [[META2]]}
; CHECK: [[LOOP5]] = distinct !{[[LOOP5]], [[META2]], [[META1]]}
;.
