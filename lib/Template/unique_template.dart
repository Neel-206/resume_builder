import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:resume_builder/models/resume_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class UniqueTemplate {
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

    // --- Define Colors & Brushes ---
    final sidebarBackgroundColor = PdfColor(220, 255, 255); // Cyan
    final mainHeaderColor = PdfColor(0, 0, 0); // Black
    final labelBackgroundColor = PdfColor(0, 0, 0); // Black
    final jobTitleColor = PdfColor(80, 80, 80); // Medium Gray
    final sectionHeaderColor = PdfColor(0, 0, 0); // Black
    final textColor = PdfColor(33, 33, 33); // Dark text

    // --- Define Fonts ---
    final PdfFont nameFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      40,
      style: PdfFontStyle.bold,
    );
    final PdfFont labelFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      13,
      style: PdfFontStyle.bold,
    );
    final PdfFont contactFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final PdfFont sidebarSectionFont = PdfStandardFont(
      PdfFontFamily.timesRoman,
      12,
      style: PdfFontStyle.bold,
    );
    final PdfFont sidebarSubHeaderFont = PdfStandardFont(
      PdfFontFamily.timesRoman,
      10,
      style: PdfFontStyle.bold,
    );
    final PdfFont sidebarBodyFont = PdfStandardFont(
      PdfFontFamily.timesRoman,
      9,
    );
    final PdfFont mainSectionFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      12,
      style: PdfFontStyle.bold,
    );
    final PdfFont mainSubHeaderFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      10,
      style: PdfFontStyle.bold,
    );
    final PdfFont mainBodyFont = PdfStandardFont(PdfFontFamily.helvetica, 9);

    // --- Border Settings ---
    final double pageMargin = 0;
    final double contentPadding = 10;
    final double cornerRadius = 12;

    // --- Define Layout ---
    final double sidebarWidth = 180;
    final double mainContentX = sidebarWidth + 15;
    final double mainContentWidth =
        pageSize.width - mainContentX - contentPadding;

    // Calculate actual content area
    final double topMargin = contentPadding;
    final double bottomMargin = contentPadding;

    double sidebarY = topMargin;
    double mainY = topMargin;
    final double sidebarX = pageMargin;

    // Draw sidebar background
    final double sidebarYPos = pageMargin;
    final double sidebarHeight = pageSize.height - (pageMargin * 2);

    final sidebarBorderPen = PdfPen(PdfColor(169, 221, 235), width: 1.5);

    // Draw sidebar background with rounded corners
    _drawRoundedRectangle(
      graphics,
      sidebarX,
      sidebarYPos,
      sidebarWidth,
      sidebarHeight,
      cornerRadius,
      PdfSolidBrush(sidebarBackgroundColor),
      sidebarBorderPen,
    );

    // Track current page index for each column
    int sidebarPageIndex = 0;
    int mainPageIndex = 0;

    // Helper function to get or create page at specific index
    PdfPage getPageAtIndex(int index) {
      while (document.pages.count <= index) {
        page = document.pages.add();
        // Draw sidebar background with rounded corners on the new page
        _drawRoundedRectangle(
          page.graphics,
          sidebarX,
          sidebarYPos,
          sidebarWidth,
          sidebarHeight,
          cornerRadius,
          PdfSolidBrush(sidebarBackgroundColor),
          sidebarBorderPen,
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

      if (sidebarY + requiredSpace > pageSize.height - bottomMargin) {
        sidebarPageIndex++;
        page = getPageAtIndex(sidebarPageIndex);
        graphics = page.graphics;
        sidebarY = topMargin;
      }
    }

    // Main content page break handler with section header protection
    void checkMainPageBreak(
      double neededSpace, {
      bool isSectionHeader = false,
    }) {
      double requiredSpace = isSectionHeader ? neededSpace + 50 : neededSpace;

      if (mainY + requiredSpace > pageSize.height - bottomMargin) {
        mainPageIndex++;
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;
        mainY = topMargin;
      }
    }

    // --- LEFT SIDEBAR ---
    page = getPageAtIndex(sidebarPageIndex);
    graphics = page.graphics;
    sidebarY = topMargin;

    final double sidebarPadding = 15;
    final double sidebarContentWidth = sidebarWidth - (sidebarPadding * 2);

    sidebarY += 10;
    // Draw underline
    graphics.drawLine(
      PdfPen(PdfColor(169, 221, 235), width: 1.5),
      Offset(sidebarX + 15, sidebarY),
      Offset(sidebarX + sidebarWidth - 15, sidebarY),
    );
    sidebarY += 5;

    // -- Education Section --
    checkSidebarPageBreak(50, isSectionHeader: true);
    page = getPageAtIndex(sidebarPageIndex);
    graphics = page.graphics;
    graphics.drawString(
      'EDUCATION',
      sidebarSectionFont,
      brush: PdfSolidBrush(textColor),
      bounds: Rect.fromLTWH(sidebarX + 15, sidebarY, sidebarContentWidth, 20),
    );
    sidebarY += 20;
    for (var edu in educationList) {
      checkSidebarPageBreak(40);
      page = getPageAtIndex(sidebarPageIndex);
      graphics = page.graphics;

      // Degree and Institution
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text:
            '${edu.degree ?? ''}(${edu.fromYear ?? ''} - ${edu.toYear ?? ''})',
        font: sidebarBodyFont,
        x: sidebarX + 15,
        y: sidebarY,
        maxWidth: sidebarContentWidth,
        lineHeight: 13,
        alignment: PdfTextAlignment.left,
      );
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text: edu.school ?? '',
        font: sidebarSubHeaderFont,
        x: sidebarX + 15,
        y: sidebarY,
        maxWidth: sidebarContentWidth,
        lineHeight: 12,
        alignment: PdfTextAlignment.left,
      );
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text: '${edu.place ?? ''}, ${edu.country ?? ''}',
        font: sidebarBodyFont,
        x: sidebarX + 15,
        y: sidebarY,
        maxWidth: sidebarContentWidth,
        lineHeight: 12,
        alignment: PdfTextAlignment.left,
      );
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text: edu.marks ?? '',
        font: sidebarBodyFont,
        x: sidebarX + 15,
        y: sidebarY,
        maxWidth: sidebarContentWidth,
        lineHeight: 12,
        alignment: PdfTextAlignment.left,
      );
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text: edu.description ?? '',
        font: sidebarBodyFont,
        x: sidebarX + 15,
        y: sidebarY,
        maxWidth: sidebarContentWidth,
        lineHeight: 11,
        alignment: PdfTextAlignment.left,
      );
      sidebarY += 13;
    }
    sidebarY += 10;

    graphics.drawLine(
      PdfPen(PdfColor(169, 221, 235), width: 1.5),
      Offset(sidebarX + 15, sidebarY),
      Offset(sidebarX + sidebarWidth - 15, sidebarY),
    );
    sidebarY += 10;

    // -- Languages Section --
    if (languagesList.isNotEmpty) {
      checkSidebarPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(sidebarPageIndex);
      graphics = page.graphics;
      graphics.drawString(
        'LANGUAGES',
        sidebarSectionFont,
        brush: PdfSolidBrush(textColor),
        bounds: Rect.fromLTWH(sidebarX + 15, sidebarY, sidebarContentWidth, 20),
      );
      sidebarY += 20;

      for (var lang in languagesList) {
        checkSidebarPageBreak(20);
        page = getPageAtIndex(sidebarPageIndex);
        graphics = page.graphics;

        String abilities = '';
        if (lang.canRead) abilities += 'Read, ';
        if (lang.canWrite) abilities += 'Write, ';
        if (lang.canSpeak) abilities += 'Speak';
        abilities = abilities.trim().replaceAll(RegExp(r',\s*$'), '');

        sidebarY =
            _drawWrappedText(
              graphics: graphics,
              text:
                  '${lang.name} ${abilities.isNotEmpty ? '($abilities)' : ''}',
              font: sidebarBodyFont,
              x: sidebarX + 15,
              y: sidebarY,
              maxWidth: sidebarContentWidth,
              lineHeight: 11,
            ) +
            5;
      }
      sidebarY += 10;
    }

    graphics.drawLine(
      PdfPen(PdfColor(169, 221, 235), width: 1.5),
      Offset(sidebarX + 15, sidebarY),
      Offset(sidebarX + sidebarWidth - 15, sidebarY),
    );
    sidebarY += 10;

    // -- Skills Section --
    if (skillsList.isNotEmpty) {
      checkSidebarPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(sidebarPageIndex);
      graphics = page.graphics;
      graphics.drawString(
        'SKILLS',
        sidebarSectionFont,
        brush: PdfSolidBrush(textColor),
        bounds: Rect.fromLTWH(sidebarX + 15, sidebarY, sidebarContentWidth, 20),
      );
      sidebarY += 20;
      final double skillNameWidth = sidebarContentWidth * 0.65;
      final double proficiencyX = sidebarX + 15 + skillNameWidth;
      final double proficiencyWidth = sidebarContentWidth - skillNameWidth;

      for (var skill in skillsList) {
        checkSidebarPageBreak(20);
        page = getPageAtIndex(sidebarPageIndex);
        graphics = page.graphics;

        // Draw Skill Name
        graphics.drawString(
          skill.name,
          sidebarBodyFont,
          brush: PdfSolidBrush(textColor),
          bounds: Rect.fromLTWH(sidebarX + 15, sidebarY, skillNameWidth, 12),
          format: PdfStringFormat(alignment: PdfTextAlignment.left),
        );

        // Draw Skill Proficiency
        if (skill.proficiency.isNotEmpty) {
          graphics.drawString(
            skill.proficiency,
            sidebarBodyFont,
            brush: PdfSolidBrush(textColor),
            bounds: Rect.fromLTWH(proficiencyX, sidebarY, proficiencyWidth, 12),
            format: PdfStringFormat(alignment: PdfTextAlignment.right),
          );
        }
        sidebarY += 13;
      }
      sidebarY += 10;
    }

    graphics.drawLine(
      PdfPen(PdfColor(169, 221, 235), width: 1.5),
      Offset(sidebarX + 15, sidebarY),
      Offset(sidebarX + sidebarWidth - 15, sidebarY),
    );
    sidebarY += 10;

    // -- Hobbies Section --
    if (hobbiesList.isNotEmpty) {
      checkSidebarPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(sidebarPageIndex);
      graphics = page.graphics;
      graphics.drawString(
        'HOBBIES',
        sidebarSectionFont,
        brush: PdfSolidBrush(textColor),
        bounds: Rect.fromLTWH(sidebarX + 15, sidebarY, sidebarContentWidth, 20),
      );
      sidebarY += 20;
      final double hobbyColumnWidth = sidebarContentWidth / 2;
      for (int i = 0; i < hobbiesList.length; i++) {
        checkSidebarPageBreak(20);
        page = getPageAtIndex(sidebarPageIndex);
        graphics = page.graphics;
        final hobby = hobbiesList[i];
        final xPos = (i % 2 == 0)
            ? sidebarX + 15
            : sidebarX + 15 + hobbyColumnWidth;

        graphics.drawString(
          '• ${hobby.name}',
          sidebarBodyFont,
          brush: PdfSolidBrush(textColor),
          bounds: Rect.fromLTWH(xPos, sidebarY, hobbyColumnWidth - 5, 12),
        );

        if (i % 2 != 0 || i == hobbiesList.length - 1) {
          sidebarY += 13;
        }
      }
      sidebarY += 5;
    }

    graphics.drawLine(
      PdfPen(PdfColor(169, 221, 235), width: 1.5),
      Offset(sidebarX + 15, sidebarY),
      Offset(sidebarX + sidebarWidth - 15, sidebarY),
    );
    sidebarY += 10;

    //--- REFERENCES SECTION ---
    if (referencesList.isNotEmpty) {
      checkSidebarPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(sidebarPageIndex);
      graphics = page.graphics;
      graphics.drawString(
        'REFERENCES',
        sidebarSectionFont,
        brush: PdfSolidBrush(textColor),
        bounds: Rect.fromLTWH(sidebarX + 15, sidebarY, sidebarContentWidth, 20),
      );
      sidebarY += 20;

      for (var ref in referencesList) {
        checkSidebarPageBreak(60);
        page = getPageAtIndex(sidebarPageIndex);
        graphics = page.graphics;

        sidebarY =
            _drawWrappedText(
              graphics: graphics,
              text: ref.name ?? '',
              font: sidebarSubHeaderFont,
              x: sidebarX + 15,
              y: sidebarY,
              maxWidth: sidebarContentWidth,
              lineHeight: 12,
            ) +
            2;
        sidebarY =
            _drawWrappedText(
              graphics: graphics,
              text: '${ref.relationship ?? ''} | ${ref.company ?? ''}',
              font: sidebarBodyFont,
              x: sidebarX + 15,
              y: sidebarY,
              maxWidth: sidebarContentWidth,
              lineHeight: 0,
            ) +
            12;
        sidebarY =
            _drawWrappedText(
              graphics: graphics,
              text: ref.email ?? '',
              font: sidebarBodyFont,
              x: sidebarX + 15,
              y: sidebarY,
              maxWidth: sidebarContentWidth,
              lineHeight: 0,
            ) +
            12;
        sidebarY += 2;
        sidebarY =
            _drawWrappedText(
              graphics: graphics,
              text: ref.phone ?? '',
              font: sidebarBodyFont,
              x: sidebarX + 15,
              y: sidebarY,
              maxWidth: sidebarContentWidth,
              lineHeight: 0,
            ) +
            12;
      }
      sidebarY += 5;
    }

    // --- RIGHT MAIN CONTENT ---
    page = getPageAtIndex(mainPageIndex);
    graphics = page.graphics;
    mainY = topMargin;

    // Draw underline
    mainY += 12;
    graphics.drawLine(
      PdfPen(PdfColor(169, 221, 235), width: 1.5),
      Offset(mainContentX, mainY),
      Offset(mainContentX + mainContentWidth, mainY),
    );
    mainY += 2;

    // -- Name Section --
    final String fullName =
        '${profileData?.firstName ?? ''} ${profileData?.lastName ?? ''}';
    final double nameWidth = nameFont.measureString(fullName).width;

    graphics.drawString(
      fullName,
      nameFont,
      brush: PdfSolidBrush(mainHeaderColor),
      bounds: Rect.fromLTWH(mainContentX, mainY, nameWidth, nameFont.height),
    );
    mainY += nameFont.height + 4;

    final String jobTitle = profileData?.jobTitle ?? '';
    final double jobTitleWidth = labelFont.measureString(jobTitle).width;
    final double jobTitleBgWidth = jobTitleWidth + 20;
    _drawRoundedRectangle(
      graphics,
      mainContentX,
      mainY,
      jobTitleBgWidth,
      labelFont.height + 5,
      5,
      PdfSolidBrush(labelBackgroundColor),
      null,
    );
    graphics.drawString(
      jobTitle,
      labelFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(
        mainContentX + 10,
        mainY + 2,
        jobTitleWidth,
        labelFont.height,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );
    mainY += labelFont.height + 25;

    // -- Contact Section --
    final String email = profileData?.email ?? '';
    final String phone = profileData?.phone ?? '';
    final double gap = 20;
    final double columnWidth = (mainContentWidth - gap) / 2;

    // Draw Email in the first column
    if (email.isNotEmpty) {
      graphics.drawString(
        email,
        contactFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(
          mainContentX,
          mainY,
          columnWidth,
          contactFont.height,
        ),
      );
    }
    // Draw Phone in the second column
    if (phone.isNotEmpty) {
      graphics.drawString(
        phone,
        contactFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(
          mainContentX + columnWidth + gap,
          mainY,
          columnWidth,
          contactFont.height,
        ),
      );
    }
    mainY += contactFont.height + 5;
    // Draw Place
    if (profileData?.country != null && profileData!.country!.isNotEmpty) {
      graphics.drawString(
        '${profileData.city},${profileData.country}',
        contactFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(
          mainContentX,
          mainY,
          columnWidth,
          contactFont.height,
        ),
      );
    }
    graphics.drawString(
      '${profileData?.linkedin ?? ''}',
      contactFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTRB(
        mainContentX + columnWidth + gap,
        mainY,
        columnWidth,
        contactFont.height,
      ),
    );

    mainY += contactFont.height + 20;
    graphics.drawLine(
      PdfPen(PdfColor(0, 0, 0), width: 1.5),
      Offset(mainContentX, mainY),
      Offset(mainContentX + mainContentWidth, mainY),
    );
    mainY += 7;

    // -- About Me Section --
    if (aboutData?.aboutText != null && aboutData!.aboutText!.isNotEmpty) {
      checkMainPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(mainPageIndex);
      graphics = page.graphics;

      graphics.drawString(
        'CAREER OBJECTIVE',
        mainSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 20),
      );
      mainY += 18;
      mainY =
          _drawWrappedText(
            graphics: graphics,
            text: aboutData.aboutText!,
            font: mainBodyFont,
            x: mainContentX,
            y: mainY,
            maxWidth: mainContentWidth,
            alignment: PdfTextAlignment.left,
            lineHeight: 13,
          ) +
          15;
    }

    graphics.drawLine(
      PdfPen(PdfColor(0, 0, 0), width: 1.5),
      Offset(mainContentX, mainY),
      Offset(mainContentX + mainContentWidth, mainY),
    );
    mainY += 5;

    // -- Awards Section --
    if (awardsList.isNotEmpty) {
      checkMainPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(mainPageIndex);
      graphics = page.graphics;
      graphics.drawString(
        'AWARDS',
        mainSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 20),
      );
      mainY += 18;

      for (var award in awardsList) {
        checkMainPageBreak(50);
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;

        // Award Name
        if (award.title != null && award.title!.isNotEmpty) {
          graphics.drawString(
            award.title!,
            mainSubHeaderFont,
            brush: PdfSolidBrush(mainHeaderColor),
            bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 12),
          );
          mainY += 14;
        }
        if (award.issuer != null && award.issuer!.isNotEmpty) {
          mainY = _drawWrappedText(
            graphics: graphics,
            text: award.issuer!,
            font: mainBodyFont,
            x: mainContentX,
            y: mainY,
            maxWidth: mainContentWidth,
            lineHeight: 0,
          );
          mainY += 13;
        }
        if (award.month != null &&
            award.month!.isNotEmpty &&
            award.year != null &&
            award.year!.isNotEmpty) {
          mainY = _drawWrappedText(
            graphics: graphics,
            text: '${award.month} ${award.year}',
            font: mainBodyFont,
            x: mainContentX,
            y: mainY,
            maxWidth: mainContentWidth,
            lineHeight: 0,
          );
          mainY += 13;
        }

        // Award Description
        if (award.description != null && award.description!.isNotEmpty) {
          mainY = _drawWrappedText(
            graphics: graphics,
            text: award.description!,
            font: mainBodyFont,
            x: mainContentX,
            y: mainY,
            maxWidth: mainContentWidth,
            lineHeight: 13,
          );
        }
        mainY += 12;
      }
    }

    graphics.drawLine(
      PdfPen(PdfColor(0, 0, 0), width: 1.5),
      Offset(mainContentX, mainY),
      Offset(mainContentX + mainContentWidth, mainY),
    );
    mainY += 5;

    // -- Experience Section --
    if (experienceList.isNotEmpty) {
      checkMainPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(mainPageIndex);
      graphics = page.graphics;

      graphics.drawString(
        'EXPERIENCES',
        mainSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 20),
      );
      mainY += 18;
      for (var exp in experienceList) {
        checkMainPageBreak(60);
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;

        graphics.drawString(
          exp.company ?? '',
          mainSubHeaderFont,
          brush: PdfSolidBrush(mainHeaderColor),
          bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 12),
        );
        mainY += 14;

        graphics.drawString(
          exp.position ?? '',
          mainBodyFont,
          brush: PdfSolidBrush(jobTitleColor),
          bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 12),
        );
        mainY += 12;
        graphics.drawString(
          '${exp.fromMonth} ${exp.fromYear} - ${exp.toMonth} ${exp.toYear}',
          mainBodyFont,
          brush: PdfSolidBrush(jobTitleColor),
          bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 12),
        );
        mainY += 12;
        mainY = _drawWrappedText(
          graphics: graphics,
          text: exp.description ?? '',
          font: mainBodyFont,
          x: mainContentX,
          y: mainY,
          maxWidth: mainContentWidth,
          lineHeight: 13,
        );
        mainY += 12;
      }
    }

    // -- Projects Section --
    if (projectsList.isNotEmpty) {
      checkMainPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(mainPageIndex);
      graphics = page.graphics;
      graphics.drawString(
        'PROJECTS',
        mainSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 20),
      );
      mainY += 18;
      graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 1.5),
        Offset(mainContentX, mainY),
        Offset(mainContentX + mainContentWidth, mainY),
      );
      mainY += 12;
      for (var project in projectsList) {
        checkMainPageBreak(60);
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;
        // Project Name
        if (project.name != null &&
            project.name!.isNotEmpty &&
            project.year != null &&
            project.year!.isNotEmpty) {
          graphics.drawString(
            project.name! + '(' + project.year! + ')',
            mainSubHeaderFont,
            brush: PdfSolidBrush(mainHeaderColor),
            bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 12),
          );
          mainY += 14;
        }
        // Project Position
        mainY = _drawWrappedText(
          graphics: graphics,
          text: project.role ?? '',
          font: mainBodyFont,
          x: mainContentX,
          y: mainY,
          maxWidth: mainContentWidth,
          lineHeight: 0,
        );
        mainY += 12;
        // Project Technology
        mainY = _drawWrappedText(
          graphics: graphics,
          text: project.technologies ?? '',
          font: mainBodyFont,
          x: mainContentX,
          y: mainY,
          maxWidth: mainContentWidth,
          lineHeight: 0,
        );
        mainY += 12;
        // Project Link
        mainY = _drawWrappedText(
          graphics: graphics,
          text: project.link ?? '',
          font: mainBodyFont,
          x: mainContentX,
          y: mainY,
          maxWidth: mainContentWidth,
          lineHeight: 0,
        );
        mainY += 12;
        // Project Description
        if (project.description != null && project.description!.isNotEmpty) {
          mainY = _drawWrappedText(
            graphics: graphics,
            text: project.description!,
            font: mainBodyFont,
            x: mainContentX,
            y: mainY,
            maxWidth: mainContentWidth,
            lineHeight: 13,
          );
        }
        mainY += 12;
      }
    }

    final List<int> bytes = await document.save();
    document.dispose();
    return Uint8List.fromList(bytes);
  }

  // Helper method to draw rounded rectangle with border
  void _drawRoundedRectangle(
    PdfGraphics graphics,
    double x,
    double y,
    double width,
    double height,
    double cornerRadius,
    PdfBrush? brush,
    PdfPen? pen,
  ) {
    final PdfPath path = PdfPath();

    path.addArc(
      Rect.fromLTWH(x, y, cornerRadius * 2, cornerRadius * 2),
      180,
      90,
    );

    path.addArc(
      Rect.fromLTWH(
        x + width - (cornerRadius * 2),
        y,
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      270,
      90,
    );

    path.addArc(
      Rect.fromLTWH(
        x + width - (cornerRadius * 2),
        y + height - (cornerRadius * 2),
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      0,
      90,
    );

    path.addArc(
      Rect.fromLTWH(
        x,
        y + height - (cornerRadius * 2),
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      90,
      90,
    );

    path.closeFigure();

    graphics.drawPath(path, pen: pen, brush: brush);
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
