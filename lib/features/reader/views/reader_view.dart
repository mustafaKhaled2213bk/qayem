import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/loading_state.dart';
import '../controllers/reader_controller.dart';
import '../widgets/reader_timer_indicator.dart';

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
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              GlassContainer(
                                borderRadius: 99.r,
                                padding: EdgeInsets.all(4.w),
                                child: IconButton(
                                  onPressed: Get.back,
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: AppColors.backgroundDark,
                                  ),
                                  tooltip: 'رجوع',
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Obx(() {
                                  if (!controller.showControls.value) {
                                    return const SizedBox.shrink();
                                  }
                                  return GlassContainer(
                                    borderRadius: 16.r,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 10.h,
                                    ),
                                    child: Text(
                                      book.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.backgroundDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              SizedBox(width: 8.w),
                              const ReaderTimerIndicator(),
                            ],
                          ),
                          Obx(() {
                            if (!controller.showTimerPanel.value) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 10.h),
                              child: const ReaderTimerPanel(),
                            );
                          }),
                        ],
                      ),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    final delegate = controller
                                        .pdfController?.textSelectionDelegate;
                                    if (delegate == null) return;
                                    await delegate.copyTextSelection();
                                    AppSnackbar.success('تم', 'تم نسخ النص');
                                  },
                                  icon: const Icon(
                                    Icons.copy_rounded,
                                    color: AppColors.secondary,
                                  ),
                                  label: Text(
                                    'نسخ',
                                    style: AppTextStyles.button.copyWith(
                                      color: Theme.of(context).brightness == Brightness.light ? AppColors.backgroundDark : AppColors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Obx(() {
                                  return TextButton.icon(
                                    onPressed: controller.isSavingQuote.value
                                        ? null
                                        : controller.saveSelectedQuote,
                                    icon: controller.isSavingQuote.value
                                        ? SizedBox(
                                            width: 18.w,
                                            height: 18.w,
                                            child:
                                                const CircularProgressIndicator(
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
                                        color: Theme.of(context).brightness == Brightness.light ? AppColors.backgroundDark : AppColors.white,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  Obx(() {
                    if (!controller.showControls.value ||
                        controller.hasTextSelection.value) {
                      return const SizedBox.shrink();
                    }
                    return SafeArea(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: GlassContainer(
                            borderRadius: 16.r,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                            child: Text(
                              'صفحة ${controller.currentPage.value} من ${controller.totalPages.value}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.backgroundDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
