import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:resume_builder/models/resume_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ClassicTemplate {
  Future<Uint8List> create({
    required Profile? profileData,
    required About? aboutData,
    required List<Education> educationList,
    required List<Experience> experienceList,
    required List<Skill> skillsList,
    required List<Award> awardsList,
    required List<Project> projectsList,
    required List<Language> languagesList,
    required List<Hobby> hobbiesList,
    required List<AppReference> referencesList,
  }) async {
    final PdfDocument document = PdfDocument();
    var page = document.pages.add();
    var pageSize = page.getClientSize();
    var graphics = page.graphics;

    graphics.drawRectangle(
      pen: PdfPens.black,
      bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
    );

    final goldColor = PdfColor(230, 201, 129);
    final sidebarBgColor = PdfColor(247, 247, 247);

    final nameFont = PdfStandardFont(PdfFontFamily.timesRoman, 25);
    final titleFont = PdfStandardFont(PdfFontFamily.timesRoman, 18);
    final sectionTitleFont = PdfStandardFont(
      PdfFontFamily.timesRoman,
      13,
      style: PdfFontStyle.bold,
    );
    final jobTitleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      12,
      style: PdfFontStyle.bold,
    );
    final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final sidebarTextFont = PdfStandardFont(PdfFontFamily.helvetica, 10);

    final String fullName =
        '${profileData?.firstName ?? ''} ${profileData?.lastName ?? ''}'
            .trim()
            .toUpperCase();
    final String jobTitle = profileData?.jobTitle ?? 'Professional Title';

    double headerY = 30;
    final double nameTextWidth = nameFont.measureString(fullName).width;
    final double boxHeight = 45;
    final double boxWidth = nameTextWidth + 100;
    final double boxX = (pageSize.width - boxWidth) / 2;
    final double titleStripHeight = 50;
    final double titleStripY = headerY + (boxHeight / 1.25);

    graphics.drawRectangle(
      brush: PdfSolidBrush(sidebarBgColor),
      bounds: Rect.fromLTWH(0, titleStripY, pageSize.width, titleStripHeight),
    );

    graphics.drawRectangle(
      pen: PdfPen(goldColor, width: 2),
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(boxX, headerY, boxWidth, boxHeight),
    );

    graphics.drawString(
      fullName,
      nameFont,
      bounds: Rect.fromLTWH(0, headerY, pageSize.width, boxHeight),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
      brush: PdfBrushes.black,
    );

    graphics.drawString(
      jobTitle,
      titleFont,
      bounds: Rect.fromLTWH(0, titleStripY, pageSize.width, titleStripHeight),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
      brush: PdfBrushes.black,
    );

    double contentStartY = titleStripY + titleStripHeight + 25;
    final double sidebarWidth = 130;
    final double sidebarX = 20;
    final double mainContentX = sidebarX + sidebarWidth + 25;
    final double mainContentWidth = pageSize.width - mainContentX - 20;
    double mainY = contentStartY;
    double sidebarY = contentStartY;

    // Track current page index for each column
    int sidebarPageIndex = 0;
    int mainPageIndex = 0;

    // Helper function to get or create page at specific index
    PdfPage getPageAtIndex(int index) {
      while (document.pages.count <= index) {
        var newPage = document.pages.add();
        newPage.graphics.drawRectangle(
          pen: PdfPens.black,
          bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        );
        // Draw separator line on new page
        newPage.graphics.drawLine(
          PdfPen(goldColor, width: 1.5),
          Offset(sidebarX + sidebarWidth + 12, 20),
          Offset(sidebarX + sidebarWidth + 12, pageSize.height - 20),
        );
      }
      return document.pages[index];
    }

    // Sidebar page break handler with section header protection
    void checkSidebarPageBreak(
      double neededSpace, {
      bool isSectionHeader = false,
    }) {
      double requiredSpace = isSectionHeader ? neededSpace + 40 : neededSpace;

      if (sidebarY + requiredSpace > pageSize.height - 30) {
        sidebarPageIndex++;
        page = getPageAtIndex(sidebarPageIndex);
        graphics = page.graphics;
        sidebarY = 30;
      }
    }

    // Main content page break handler with section header protection
    void checkMainPageBreak(
      double neededSpace, {
      bool isSectionHeader = false,
    }) {
      double requiredSpace = isSectionHeader ? neededSpace + 50 : neededSpace;

      if (mainY + requiredSpace > pageSize.height - 30) {
        mainPageIndex++;
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;
        mainY = 30;
      }
    }

    // Draw initial separator line
    graphics.drawLine(
      PdfPen(goldColor, width: 1.5),
      Offset(sidebarX + sidebarWidth + 12, contentStartY - 10),
      Offset(sidebarX + sidebarWidth + 12, pageSize.height - 20),
    );

    // --- SIDEBAR CONTENT ---
    page = getPageAtIndex(sidebarPageIndex);
    graphics = page.graphics;

    checkSidebarPageBreak(50, isSectionHeader: true);
    graphics.drawString(
      'CONTACT',
      sectionTitleFont,
      bounds: Rect.fromLTWH(sidebarX, sidebarY, sidebarWidth, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
      brush: PdfBrushes.black,
    );
    sidebarY += 22;

    final contactLines = [
      profileData?.email ?? 'default.email@example.com',
      profileData?.phone ?? '(123) 456-7890',
      profileData?.address ?? '123 Main St',
      '${profileData?.city ?? 'City'} ${profileData?.country ?? 'Country'}',
      profileData?.pincode ?? '000000',
      profileData?.linkedin,
      profileData?.github,
    ];

    for (final line in contactLines) {
      if (line != null && line.isNotEmpty) {
        checkSidebarPageBreak(20);
        page = getPageAtIndex(sidebarPageIndex);
        graphics = page.graphics;
        sidebarY = _drawWrappedText(
          graphics: graphics,
          text: line,
          font: sidebarTextFont,
          x: sidebarX,
          y: sidebarY,
          maxWidth: sidebarWidth,
          lineHeight: 14,
          alignment: PdfTextAlignment.left,
        );
      }
    }

    sidebarY += 20;
    checkSidebarPageBreak(50, isSectionHeader: true);
    page = getPageAtIndex(sidebarPageIndex);
    graphics = page.graphics;
    graphics.drawString(
      'EDUCATION',
      sectionTitleFont,
      bounds: Rect.fromLTWH(sidebarX, sidebarY, sidebarWidth, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
      brush: PdfBrushes.black,
    );
    sidebarY += 22;

    for (final edu in educationList) {
      checkSidebarPageBreak(80);
      page = getPageAtIndex(sidebarPageIndex);
      graphics = page.graphics;
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text: edu.degree ?? 'Degree',
        font: sidebarTextFont,
        x: sidebarX,
        y: sidebarY,
        maxWidth: sidebarWidth,
        lineHeight: 14,
        alignment: PdfTextAlignment.left,
      );
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text: edu.school ?? 'University',
        font: sidebarTextFont,
        x: sidebarX,
        y: sidebarY,
        maxWidth: sidebarWidth,
        lineHeight: 14,
        alignment: PdfTextAlignment.left,
      );
      graphics.drawString(
        '${edu.fromYear ?? 'YYYY'} - ${edu.toYear ?? 'YYYY'}',
        sidebarTextFont,
        bounds: Rect.fromLTWH(sidebarX, sidebarY, sidebarWidth, 14),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.black,
      );
      sidebarY += 14;
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text: '${edu.place ?? 'City'}, ${edu.country ?? 'Country'}',
        font: sidebarTextFont,
        x: sidebarX,
        y: sidebarY,
        maxWidth: sidebarWidth,
        lineHeight: 14,
        alignment: PdfTextAlignment.left,
      );
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text: edu.marks ?? '',
        font: sidebarTextFont,
        x: sidebarX,
        y: sidebarY,
        maxWidth: sidebarWidth,
        lineHeight: 13,
        alignment: PdfTextAlignment.left,
      );
      sidebarY += 10;
    }

    sidebarY += 10;
    checkSidebarPageBreak(50, isSectionHeader: true);
    page = getPageAtIndex(sidebarPageIndex);
    graphics = page.graphics;
    graphics.drawString(
      'SKILLS',
      sectionTitleFont,
      bounds: Rect.fromLTWH(sidebarX, sidebarY, sidebarWidth, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
      brush: PdfBrushes.black,
    );
    sidebarY += 22;

    final double skillNameWidth = sidebarWidth * 0.6;
    final double proficiencyX = sidebarX + skillNameWidth;
    final double proficiencyWidth = sidebarWidth - skillNameWidth;

    for (final skill in skillsList) {
      checkSidebarPageBreak(20);
      page = getPageAtIndex(sidebarPageIndex);
      graphics = page.graphics;
      graphics.drawString(
        skill.name,
        sidebarTextFont,
        bounds: Rect.fromLTWH(sidebarX, sidebarY, skillNameWidth, 14),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.black,
      );
      graphics.drawString(
        skill.proficiency,
        sidebarTextFont,
        bounds: Rect.fromLTWH(proficiencyX, sidebarY, proficiencyWidth, 14),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        brush: PdfBrushes.darkGray,
      );
      sidebarY += 14;
    }

    sidebarY += 20;
    checkSidebarPageBreak(50, isSectionHeader: true);
    page = getPageAtIndex(sidebarPageIndex);
    graphics = page.graphics;
    graphics.drawString(
      'CERTIFICATIONS',
      sectionTitleFont,
      bounds: Rect.fromLTWH(sidebarX, sidebarY, sidebarWidth, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
      brush: PdfBrushes.black,
    );
    sidebarY += 22;

    if (awardsList.isNotEmpty) {
      for (final cert in awardsList) {
        checkSidebarPageBreak(80);
        page = getPageAtIndex(sidebarPageIndex);
        graphics = page.graphics;
        sidebarY = _drawWrappedText(
          graphics: graphics,
          text: cert.title ?? '',
          font: sidebarTextFont,
          x: sidebarX,
          y: sidebarY,
          maxWidth: sidebarWidth,
          lineHeight: 13,
          alignment: PdfTextAlignment.left,
        );
        sidebarY = _drawWrappedText(
          graphics: graphics,
          text: cert.issuer ?? '',
          font: sidebarTextFont,
          x: sidebarX,
          y: sidebarY,
          maxWidth: sidebarWidth,
          lineHeight: 13,
          alignment: PdfTextAlignment.left,
        );
        sidebarY = _drawWrappedText(
          graphics: graphics,
          text: '${cert.year ?? 'YYYY'} - ${cert.month ?? 'MM'}',
          font: sidebarTextFont,
          x: sidebarX,
          y: sidebarY,
          maxWidth: sidebarWidth,
          lineHeight: 13,
          alignment: PdfTextAlignment.left,
        );
        sidebarY = _drawWrappedText(
          graphics: graphics,
          text: cert.description ?? '',
          font: sidebarTextFont,
          x: sidebarX,
          y: sidebarY,
          maxWidth: sidebarWidth,
          lineHeight: 13,
          alignment: PdfTextAlignment.left,
        );
        sidebarY += 15;
      }
    } else {
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text: 'No Certifications Listed',
        font: sidebarTextFont,
        x: sidebarX,
        y: sidebarY,
        maxWidth: sidebarWidth,
        lineHeight: 13,
        alignment: PdfTextAlignment.left,
      );
    }

    // --- MAIN CONTENT COLUMN ---
    page = getPageAtIndex(mainPageIndex);
    graphics = page.graphics;
    mainY = contentStartY;

    checkMainPageBreak(50, isSectionHeader: true);
    page = getPageAtIndex(mainPageIndex);
    graphics = page.graphics;
    graphics.drawString(
      'CAREER OBJECTIVE',
      sectionTitleFont,
      bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 20),
      brush: PdfBrushes.black,
    );
    mainY += 22;

    final objective =
        aboutData?.aboutText ?? 'A summary of your career objective...';
    mainY = _drawWrappedText(
      graphics: graphics,
      text: objective,
      font: bodyFont,
      x: mainContentX,
      y: mainY,
      maxWidth: mainContentWidth,
      lineHeight: 13,
    );
    mainY += 15;

    if (projectsList.isNotEmpty) {
      checkMainPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(mainPageIndex);
      graphics = page.graphics;
      graphics.drawString(
        'PROJECTS',
        sectionTitleFont,
        bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 20),
      );
      mainY += 22;

      for (final project in projectsList) {
        checkMainPageBreak(100);
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;
        graphics.drawString(
          project.name ?? 'Project Name',
          jobTitleFont,
          bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 16),
          brush: PdfBrushes.black,
        );
        mainY += 16;
        graphics.drawString(
          project.role ?? 'Role',
          bodyFont,
          bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 14),
          brush: PdfBrushes.black,
        );
        mainY += 14;
        mainY = _drawWrappedText(
          graphics: graphics,
          text: project.description ?? 'Project Description',
          font: bodyFont,
          x: mainContentX,
          y: mainY,
          maxWidth: mainContentWidth,
          lineHeight: 13,
        );
        graphics.drawString(
          'Technologies: ${project.technologies ?? 'N/A'}',
          bodyFont,
          bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 14),
          brush: PdfBrushes.darkGray,
        );
        mainY += 14;
        graphics.drawString(
          'Link: ${project.link ?? 'N/A'}',
          bodyFont,
          bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 14),
          brush: PdfBrushes.darkGray,
        );
        mainY += 14;
        graphics.drawString(
          'Year: ${project.year ?? 'N/A'}',
          bodyFont,
          bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 14),
          brush: PdfBrushes.darkGray,
        );
        mainY += 20;
      }
    }
    checkMainPageBreak(50, isSectionHeader: true);
    page = getPageAtIndex(mainPageIndex);
    graphics = page.graphics;
    graphics.drawString(
      'WORK EXPERIENCE',
      sectionTitleFont,
      bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 20),
      brush: PdfBrushes.black,
    );
    mainY += 22;

    if (experienceList.isEmpty) {
      // Show "Fresher" when no experience is added
      graphics.drawString(
        'Fresher',
        jobTitleFont,
        bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 16),
        brush: PdfBrushes.black,
      );
      mainY += 30;
    } else {
      for (final exp in experienceList) {
        checkMainPageBreak(100);
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;
        graphics.drawString(
          exp.position ?? 'Position',
          jobTitleFont,
          bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 16),
          brush: PdfBrushes.black,
        );
        mainY += 16;
        graphics.drawString(
          exp.company ?? 'Company Name',
          bodyFont,
          bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 14),
          brush: PdfBrushes.black,
        );
        mainY += 14;
        final location = 'City, Country';
        graphics.drawString(
          '${exp.fromYear ?? 'YYYY'} - ${exp.toYear ?? 'YYYY'}  /  $location',
          bodyFont,
          bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 14),
          brush: PdfBrushes.black,
        );
        mainY += 16;
        mainY = _drawWrappedText(
          graphics: graphics,
          text: exp.description ?? '',
          font: bodyFont,
          x: mainContentX,
          y: mainY,
          maxWidth: mainContentWidth,
          lineHeight: 13,
        );
        mainY += 15;
      }
    }

    checkMainPageBreak(50, isSectionHeader: true);
    page = getPageAtIndex(mainPageIndex);
    graphics = page.graphics;
    graphics.drawString(
      'LANGUAGES',
      sectionTitleFont,
      bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 20),
      brush: PdfBrushes.black,
    );
    mainY += 22;

    if (languagesList.isNotEmpty) {
      for (final lang in languagesList) {
        checkMainPageBreak(20);
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;
        String abilities = '';
        if (lang.canRead) abilities += 'Read,';
        if (lang.canWrite) abilities += 'Write,';
        if (lang.canSpeak) abilities += 'Speak';

        mainY = _drawWrappedText(
          graphics: graphics,
          text: '${lang.name} (${abilities.trim()})',
          font: bodyFont,
          x: mainContentX,
          y: mainY,
          maxWidth: mainContentWidth,
          lineHeight: 13,
        );
      }
    }

    mainY += 20;
    checkMainPageBreak(50, isSectionHeader: true);
    page = getPageAtIndex(mainPageIndex);
    graphics = page.graphics;
    graphics.drawString(
      'HOBBIES',
      sectionTitleFont,
      bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 20),
      brush: PdfBrushes.black,
    );
    mainY += 22;

    if (hobbiesList.isNotEmpty) {
      for (final hobby in hobbiesList) {
        checkMainPageBreak(20);
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;
        mainY = _drawWrappedText(
          graphics: graphics,
          text: hobby.name,
          font: bodyFont,
          x: mainContentX,
          y: mainY,
          maxWidth: mainContentWidth,
          lineHeight: 13,
        );
      }
    }

    final List<int> bytes = await document.save();
    document.dispose();
    return Uint8List.fromList(bytes);
  }

  double _drawWrappedText({
    required PdfGraphics graphics,
    required String text,
    required PdfFont font,
    required double x,
    required double y,
    required double maxWidth,
    required double lineHeight,
    PdfTextAlignment alignment = PdfTextAlignment.left,
  }) {
    if (text.isEmpty) return y;
    final words = text.split(' ');
    String currentLine = '';
    double currentY = y;

    for (int i = 0; i < words.length; i++) {
      final testLine = currentLine.isEmpty
          ? words[i]
          : '$currentLine ${words[i]}';
      final testWidth = font.measureString(testLine).width;

      if (testWidth > maxWidth && currentLine.isNotEmpty) {
        graphics.drawString(
          currentLine,
          font,
          bounds: Rect.fromLTWH(x, currentY, maxWidth, lineHeight),
          format: PdfStringFormat(alignment: alignment),
          brush: PdfBrushes.black,
        );
        currentY += lineHeight;
        currentLine = words[i];
      } else {
        currentLine = testLine;
      }
    }

    if (currentLine.isNotEmpty) {
      graphics.drawString(
        currentLine,
        font,
        bounds: Rect.fromLTWH(x, currentY, maxWidth, lineHeight),
        format: PdfStringFormat(alignment: alignment),
        brush: PdfBrushes.black,
      );
      currentY += lineHeight;
    }

    return currentY;
  }
}
