import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/loading_state.dart';
import '../controllers/reader_controller.dart';

class ReaderView extends GetView<ReaderController> {
  const ReaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          switch (controller.readerState.value) {
            case ReaderState.loading:
              return const LoadingState(message: 'جاري فتح الكتاب...');
            case ReaderState.missingFile:
            case ReaderState.error:
              return EmptyState(
                title: 'تعذّر فتح الكتاب',
                subtitle: controller.errorMessage.value,
                actionLabel: 'رجوع',
                onAction: Get.back,
                icon: Icons.picture_as_pdf_outlined,
              );
            case ReaderState.ready:
              final book = controller.book.value!;
              return Stack(
                children: [
                  PdfViewer.file(
                    book.filePath,
                    controller: controller.pdfController,
                    initialPageNumber: controller.currentPage.value,
                    params: PdfViewerParams(
                      onPageChanged: controller.onPageChanged,
                      onViewerReady: (document, _) {
                        controller.onDocumentReady(document);
                      },
                      onGeneralTap: controller.onGeneralTap,
                      textSelectionParams: PdfTextSelectionParams(
                        enabled: true,
                        showContextMenuAutomatically: true,
                        onTextSelectionChange:
                            controller.onTextSelectionChange,
                      ),
                      customizeContextMenuItems: (params, items) {
                        if (params.textSelectionDelegate.hasSelectedText) {
                          items.insert(
                            0,
                            ContextMenuButtonItem(
                              label: 'اقتباس',
                              onPressed: () {
                                params.dismissContextMenu();
                                controller.saveSelectedQuote(
                                  selectionDelegate:
                                      params.textSelectionDelegate,
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Obx(() {
                    if (!controller.hasTextSelection.value) {
                      return const SizedBox.shrink();
                    }
                    return SafeArea(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
                          child: GlassContainer(
                            borderRadius: 18.r,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            child: Obx(() {
                              return TextButton.icon(
                                onPressed: controller.isSavingQuote.value
                                    ? null
                                    : controller.saveSelectedQuote,
                                icon: controller.isSavingQuote.value
                                    ? SizedBox(
                                        width: 18.w,
                                        height: 18.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.format_quote_rounded,
                                        color: AppColors.secondary,
                                      ),
                                label: Text(
                                  'اقتباس',
                                  style: AppTextStyles.button.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    );
                  }),
                  Obx(() {
                    if (!controller.showControls.value) {
                      return const SizedBox.shrink();
                    }
                    return SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          children: [
                            GlassContainer(
                              borderRadius: 16.r,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: Get.back,
                                    icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      book.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.subtitle.copyWith(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: controller.showTimer,
                                    icon: const Icon(
                                      Icons.timer_outlined,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            GlassContainer(
                              borderRadius: 16.r,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                              child: Obx(() {
                                return Text(
                                  'صفحة ${controller.currentPage.value} من ${controller.totalPages.value}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
          }
        }),
      ),
    );
  }
}
