import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:resume_builder/models/resume_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ProfessionalTemplate {
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
    final sidebarBackgroundColor = PdfColor(186, 140, 50); // Gold/Yellow-brown
    final mainHeaderColor = PdfColor(0, 0, 0); // Black
    final jobTitleColor = PdfColor(80, 80, 80); // Medium Gray
    final sectionHeaderColor = PdfColor(0, 0, 0); // Black
    final textColor = PdfColor(255, 255, 255); // White text for sidebar
    final mainTextColor = PdfColor(33, 33, 33); // Dark text for main content

    // --- Define Fonts ---
    final PdfFont nameFont = PdfStandardFont(
      PdfFontFamily.timesRoman,
      20,
      style: PdfFontStyle.bold,
    );
    final PdfFont sidebarSectionFont = PdfStandardFont(
      PdfFontFamily.timesRoman,
      13,
      style: PdfFontStyle.bold,
    );
    final PdfFont sidebarSubHeaderFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      9,
      style: PdfFontStyle.bold,
    );
    final PdfFont sidebarBodyFont = PdfStandardFont(PdfFontFamily.helvetica, 8);
    final PdfFont mainSubHeaderFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      10,
      style: PdfFontStyle.bold,
    );
    final PdfFont mainBodyFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    final PdfFont mainDateFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      8,
      style: PdfFontStyle.italic,
    );

    // --- Border Settings ---
    final double pageMargin = 0;
    final double contentPadding = 10;
    final double cornerRadius = 12;

    // --- Define Layout ---
    final double sidebarWidth = 200;
    final double mainContentX = sidebarWidth + 20;
    final double mainContentWidth = pageSize.width - mainContentX - contentPadding;

    // Calculate actual content area
    final double topMargin = contentPadding;
    final double bottomMargin = contentPadding;

    double sidebarY = topMargin + 15;
    double mainY = topMargin + 10;
    final double sidebarX = pageMargin;

    // Track current page index for each column
    int sidebarPageIndex = 0;
    int mainPageIndex = 0;

    // Helper function to get or create page at specific index
    PdfPage getPageAtIndex(int index) {
      while (document.pages.count <= index) {
        page = document.pages.add();
      }
      return document.pages[index];
    }

    // Sidebar page break handler with section header protection
    void checkSidebarPageBreak(double neededSpace, {bool isSectionHeader = false}) {
      double requiredSpace = isSectionHeader ? neededSpace + 40 : neededSpace;
      
      if (sidebarY + requiredSpace > pageSize.height - bottomMargin) {
        sidebarPageIndex++;
        page = getPageAtIndex(sidebarPageIndex);
        graphics = page.graphics;
        sidebarY = topMargin + 15;
      }
    }

    // Main content page break handler with section header protection
    void checkMainPageBreak(double neededSpace, {bool isSectionHeader = false}) {
      double requiredSpace = isSectionHeader ? neededSpace + 50 : neededSpace;
      
      if (mainY + requiredSpace > pageSize.height - bottomMargin) {
        mainPageIndex++;
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;
        mainY = topMargin + 10;
      }
    }

    // --- LEFT SIDEBAR ---
    page = getPageAtIndex(sidebarPageIndex);
    graphics = page.graphics;

    final double sidebarPadding = 20;
    final double sidebarContentWidth = sidebarWidth - (sidebarPadding * 2);

    // --- Draw Sidebar Header Background FIRST ---
    double tempY = sidebarY;
    tempY += _calculateWrappedTextHeight(
      text: '${profileData?.firstName ?? ''} ${profileData?.lastName ?? ''}',
      font: PdfStandardFont(
        PdfFontFamily.helvetica,
        20,
        style: PdfFontStyle.bold,
      ),
      maxWidth: sidebarContentWidth,
      lineHeight: 24,
    );
    tempY += 5;
    tempY += _calculateWrappedTextHeight(
      text: profileData?.jobTitle?.toUpperCase() ?? '',
      font: sidebarSubHeaderFont,
      maxWidth: sidebarContentWidth,
      lineHeight: 12,
    );
    tempY += 7;
    if (profileData?.email != null && profileData!.email!.isNotEmpty) {
      tempY +=
          _calculateWrappedTextHeight(
            text: profileData.email!,
            font: sidebarBodyFont,
            maxWidth: sidebarContentWidth - 15,
            lineHeight: 11,
          ) +
          8;
    }
    if (profileData?.phone != null && profileData!.phone!.isNotEmpty) {
      tempY +=
          _calculateWrappedTextHeight(
            text: profileData.phone!,
            font: sidebarBodyFont,
            maxWidth: sidebarContentWidth - 15,
            lineHeight: 11,
          ) +
          8;
    }
    if (profileData?.city != null && profileData!.city!.isNotEmpty) {
      tempY +=
          _calculateWrappedTextHeight(
            text: '${profileData.city}, ${profileData.country ?? ''}',
            font: sidebarBodyFont,
            maxWidth: sidebarContentWidth - 15,
            lineHeight: 11,
          ) +
          8;
    }
    if (profileData?.linkedin != null && profileData!.linkedin!.isNotEmpty) {
      tempY +=
          _calculateWrappedTextHeight(
            text: profileData.linkedin!,
            font: sidebarBodyFont,
            maxWidth: sidebarContentWidth - 15,
            lineHeight: 11,
          ) +
          15;
    }
    final double headerHeight = tempY - sidebarY;
    _drawRoundedRectangle(
      graphics,
      sidebarX,
      sidebarY - 15,
      sidebarWidth,
      headerHeight + 15,
      cornerRadius,
      PdfSolidBrush(sidebarBackgroundColor),
      null,
    );

    // Name and Title in sidebar
    final String fullName =
        '${profileData?.firstName ?? ''} ${profileData?.lastName ?? ''}';

    sidebarY = _drawWrappedText(
      graphics: graphics,
      text: fullName,
      font: nameFont,
      x: sidebarX + sidebarPadding,
      y: sidebarY,
      maxWidth: sidebarContentWidth,
      lineHeight: 24,
      brush: PdfSolidBrush(textColor),
    );
    sidebarY += 5;

    // Job Title
    sidebarY = _drawWrappedText(
      graphics: graphics,
      text: profileData?.jobTitle?.toUpperCase() ?? '',
      font: sidebarSubHeaderFont,
      x: sidebarX + sidebarPadding,
      y: sidebarY,
      maxWidth: sidebarContentWidth,
      lineHeight: 12,
      brush: PdfSolidBrush(textColor),
    );
    sidebarY += 15;

    // Contact Info in sidebar
    if (profileData?.email != null && profileData!.email!.isNotEmpty) {
      graphics.drawString(
        'E: ',
        sidebarSubHeaderFont,
        brush: PdfSolidBrush(textColor),
        bounds: Rect.fromLTWH(sidebarX + sidebarPadding, sidebarY, 15, 11),
      );
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text: profileData.email!,
        font: sidebarBodyFont,
        x: sidebarX + sidebarPadding + 15,
        y: sidebarY,
        maxWidth: sidebarContentWidth - 15,
        lineHeight: 11,
        brush: PdfSolidBrush(textColor),
      );
      sidebarY += 3;
    }

    if (profileData?.phone != null && profileData!.phone!.isNotEmpty) {
      graphics.drawString(
        'P: ',
        sidebarSubHeaderFont,
        brush: PdfSolidBrush(textColor),
        bounds: Rect.fromLTWH(sidebarX + sidebarPadding, sidebarY, 15, 11),
      );
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text: profileData.phone!,
        font: sidebarBodyFont,
        x: sidebarX + sidebarPadding + 15,
        y: sidebarY,
        maxWidth: sidebarContentWidth - 15,
        lineHeight: 11,
        brush: PdfSolidBrush(textColor),
      );
      sidebarY += 3;
    }

    if (profileData?.city != null && profileData!.city!.isNotEmpty) {
      graphics.drawString(
        'L: ',
        sidebarSubHeaderFont,
        brush: PdfSolidBrush(textColor),
        bounds: Rect.fromLTWH(sidebarX + sidebarPadding, sidebarY, 15, 11),
      );
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text: '${profileData.city}, ${profileData.country ?? ''}',
        font: sidebarBodyFont,
        x: sidebarX + sidebarPadding + 15,
        y: sidebarY,
        maxWidth: sidebarContentWidth - 15,
        lineHeight: 11,
        brush: PdfSolidBrush(textColor),
      );
      sidebarY += 3;
    }

    if (profileData?.linkedin != null && profileData!.linkedin!.isNotEmpty) {
      graphics.drawString(
        'in: ',
        sidebarSubHeaderFont,
        brush: PdfSolidBrush(textColor),
        bounds: Rect.fromLTWH(sidebarX + sidebarPadding, sidebarY, 15, 11),
      );
      sidebarY = _drawWrappedText(
        graphics: graphics,
        text: profileData.linkedin!,
        font: sidebarBodyFont,
        x: sidebarX + sidebarPadding + 15,
        y: sidebarY,
        maxWidth: sidebarContentWidth - 15,
        lineHeight: 11,
        brush: PdfSolidBrush(textColor),
      );
      sidebarY += 20;
    }

    // -- Education Section --
    checkSidebarPageBreak(50, isSectionHeader: true);
    page = getPageAtIndex(sidebarPageIndex);
    graphics = page.graphics;

    sidebarY += 18;
    graphics.drawString(
      'EDUCATION',
      sidebarSectionFont,
      brush: PdfSolidBrush(PdfColor(186, 140, 50)),
      bounds: Rect.fromLTWH(
        sidebarX + sidebarPadding,
        sidebarY,
        sidebarContentWidth,
        15,
      ),
    );
    sidebarY += 18;

    for (var edu in educationList) {
      checkSidebarPageBreak(60);
      page = getPageAtIndex(sidebarPageIndex);
      graphics = page.graphics;

      // Degree
      if (edu.degree != null && edu.degree!.isNotEmpty) {
        sidebarY = _drawWrappedText(
          graphics: graphics,
          text: edu.degree!,
          font: sidebarSubHeaderFont,
          x: sidebarX + sidebarPadding,
          y: sidebarY,
          maxWidth: sidebarContentWidth,
          lineHeight: 11,
          brush: PdfSolidBrush(mainTextColor),
        );
        sidebarY += 3;
      }

      // School
      if (edu.school != null && edu.school!.isNotEmpty) {
        sidebarY = _drawWrappedText(
          graphics: graphics,
          text: edu.school!,
          font: sidebarBodyFont,
          x: sidebarX + sidebarPadding,
          y: sidebarY,
          maxWidth: sidebarContentWidth,
          lineHeight: 10,
          brush: PdfSolidBrush(mainTextColor),
        );
        sidebarY += 3;
      }

      // Years
      String years = '';
      if (edu.fromYear != null && edu.toYear != null) {
        years = '${edu.fromYear} - ${edu.toYear}';
      }
      if (years.isNotEmpty) {
        sidebarY = _drawWrappedText(
          graphics: graphics,
          text: years,
          font: sidebarBodyFont,
          x: sidebarX + sidebarPadding,
          y: sidebarY,
          maxWidth: sidebarContentWidth,
          lineHeight: 10,
          brush: PdfSolidBrush(mainTextColor),
        );
        sidebarY += 3;
      }

      // Marks
      if (edu.marks != null && edu.marks!.isNotEmpty) {
        sidebarY = _drawWrappedText(
          graphics: graphics,
          text: edu.marks!,
          font: sidebarBodyFont,
          x: sidebarX + sidebarPadding,
          y: sidebarY,
          maxWidth: sidebarContentWidth,
          lineHeight: 10,
          brush: PdfSolidBrush(mainTextColor),
        );
        sidebarY += 3;
      }
      if (edu.description != null && edu.description!.isNotEmpty) {
        sidebarY = _drawWrappedText(
          graphics: graphics,
          text: edu.description!,
          font: sidebarBodyFont,
          x: sidebarX + sidebarPadding,
          y: sidebarY,
          maxWidth: sidebarContentWidth,
          lineHeight: 10,
          brush: PdfSolidBrush(mainTextColor),
        );
        sidebarY += 10;
      }
      sidebarY += 5;
    }

    // -- Languages Section --
    if (languagesList.isNotEmpty) {
      checkSidebarPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(sidebarPageIndex);
      graphics = page.graphics;

      graphics.drawString(
        'LANGUAGES',
        sidebarSectionFont,
        brush: PdfSolidBrush(PdfColor(186, 140, 50)),
        bounds: Rect.fromLTWH(
          sidebarX + sidebarPadding,
          sidebarY,
          sidebarContentWidth,
          15,
        ),
      );
      sidebarY += 18;

      for (var lang in languagesList) {
        checkSidebarPageBreak(20);
        page = getPageAtIndex(sidebarPageIndex);
        graphics = page.graphics;

        String abilities = '';
        if (lang.canRead) abilities += 'Read, ';
        if (lang.canWrite) abilities += 'Write, ';
        if (lang.canSpeak) abilities += 'Speak';
        abilities = abilities.trim().replaceAll(RegExp(r',\s*$'), '');

        String langText = lang.name;
        if (abilities.isNotEmpty) {
          langText += ' ($abilities)';
        }

        sidebarY = _drawWrappedText(
          graphics: graphics,
          text: langText,
          font: sidebarBodyFont,
          x: sidebarX + sidebarPadding,
          y: sidebarY,
          maxWidth: sidebarContentWidth,
          lineHeight: 11,
          brush: PdfSolidBrush(mainTextColor),
        );
      }
      sidebarY += 15;
    }

    // -- Skills Section --
    if (skillsList.isNotEmpty) {
      checkSidebarPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(sidebarPageIndex);
      graphics = page.graphics;

      graphics.drawString(
        'SKILLS',
        sidebarSectionFont,
        brush: PdfSolidBrush(PdfColor(186, 140, 50)),
        bounds: Rect.fromLTWH(
          sidebarX + sidebarPadding,
          sidebarY,
          sidebarContentWidth,
          15,
        ),
      );
      sidebarY += 18;

      for (var skill in skillsList) {
        checkSidebarPageBreak(25);
        page = getPageAtIndex(sidebarPageIndex);
        graphics = page.graphics;

        // Skill name
        sidebarY = _drawWrappedText(
          graphics: graphics,
          text: skill.name,
          font: sidebarBodyFont,
          x: sidebarX + sidebarPadding,
          y: sidebarY,
          maxWidth: sidebarContentWidth,
          lineHeight: 11,
          brush: PdfSolidBrush(mainTextColor),
        );

        // Proficiency level
        if (skill.proficiency.isNotEmpty) {
          graphics.drawString(
            skill.proficiency,
            sidebarBodyFont,
            brush: PdfSolidBrush(mainTextColor),
            bounds: Rect.fromLTWH(
              sidebarX + sidebarPadding + sidebarContentWidth - 60,
              sidebarY - 11,
              60,
              11,
            ),
            format: PdfStringFormat(alignment: PdfTextAlignment.right),
          );
        }
        sidebarY += 5;
      }
      sidebarY += 8;
    }

    // --- RIGHT MAIN CONTENT ---
    page = getPageAtIndex(mainPageIndex);
    graphics = page.graphics;
    mainY = topMargin + 10;

    // -- Career Objective Section --
    if (aboutData?.aboutText != null && aboutData!.aboutText!.isNotEmpty) {
      checkMainPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(mainPageIndex);
      graphics = page.graphics;

      graphics.drawString(
        'CAREER OBJECTIVE',
        sidebarSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 15),
      );
      mainY += 18;
      mainY = _drawWrappedText(
        graphics: graphics,
        text: aboutData.aboutText!,
        font: mainBodyFont,
        x: mainContentX,
        y: mainY,
        maxWidth: mainContentWidth,
        lineHeight: 12,
        brush: PdfSolidBrush(mainTextColor),
      );
      mainY += 15;
    }

    // -- Experience Section --
    checkMainPageBreak(50, isSectionHeader: true);
    page = getPageAtIndex(mainPageIndex);
    graphics = page.graphics;

    graphics.drawString(
      'WORK EXPERIENCE',
      sidebarSectionFont,
      brush: PdfSolidBrush(sectionHeaderColor),
      bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 15),
    );
    mainY += 18;

    if (experienceList.isEmpty) {
      graphics.drawString(
        'Fresher',
        mainSubHeaderFont,
        brush: PdfSolidBrush(mainHeaderColor),
        bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 12),
      );
      mainY += 14;
    } else {

      for (var exp in experienceList) {
        checkMainPageBreak(70);
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;

        // Position
        double currentX = mainContentX;
        if (exp.position != null && exp.position!.isNotEmpty) {
          final positionSize = mainSubHeaderFont.measureString(exp.position!);
          graphics.drawString(
            exp.position!,
            mainSubHeaderFont,
            brush: PdfSolidBrush(mainTextColor),
            bounds: Rect.fromLTWH(currentX, mainY, positionSize.width, 12),
          );
          currentX += positionSize.width;
        }

        // Separator and Company
        if (exp.company != null && exp.company!.isNotEmpty) {
          String separator = (exp.position != null && exp.position!.isNotEmpty)
              ? ' | '
              : '';
          final separatorSize = mainSubHeaderFont.measureString(separator);
          if (separator.isNotEmpty) {
            graphics.drawString(
              separator,
              mainSubHeaderFont,
              brush: PdfSolidBrush(mainHeaderColor),
              bounds: Rect.fromLTWH(currentX, mainY, separatorSize.width, 12),
            );
            currentX += separatorSize.width;
          }

          final companyText = exp.company!;
          graphics.drawString(
            companyText,
            mainSubHeaderFont,
            brush: PdfSolidBrush(mainHeaderColor),
            bounds: Rect.fromLTWH(
              currentX,
              mainY,
              mainContentWidth - (currentX - mainContentX),
              12,
            ),
          );
        }
        mainY += 13;

        // Date range
        String dateRange = '';
        if (exp.fromMonth != null && exp.fromYear != null) {
          dateRange = '${exp.fromMonth} ${exp.fromYear} - ';
          if (exp.toMonth != null && exp.toYear != null) {
            dateRange += '${exp.toMonth} ${exp.toYear}';
          } else {
            dateRange += 'Present';
          }
        }

        if (dateRange.isNotEmpty) {
          graphics.drawString(
            dateRange,
            mainDateFont,
            brush: PdfSolidBrush(jobTitleColor),
            bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 11),
          );
          mainY += 12;
        }

        // Description with bullets
        if (exp.description != null && exp.description!.isNotEmpty) {
          final descLines = exp.description!.split('\n');
          for (var line in descLines) {
            if (line.trim().isNotEmpty) {
              // Draw bullet
              graphics.drawString(
                '•',
                mainBodyFont,
                brush: PdfSolidBrush(mainTextColor),
                bounds: Rect.fromLTWH(mainContentX, mainY, 10, 11),
              );

              mainY = _drawWrappedText(
                graphics: graphics,
                text: line.trim(),
                font: mainBodyFont,
                x: mainContentX + 15,
                y: mainY,
                maxWidth: mainContentWidth - 15,
                lineHeight: 12,
                brush: PdfSolidBrush(mainTextColor),
              );
              mainY += 3;
            }
          }
        }
        mainY += 10;
      }
    }

    // -- Awards Section --
    if (awardsList.isNotEmpty) {
      checkMainPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(mainPageIndex);
      graphics = page.graphics;

      graphics.drawString(
        'AWARDS',
        sidebarSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 15),
      );
      mainY += 18;

      for (var award in awardsList) {
        checkMainPageBreak(50);
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;

        // Award title
        if (award.title != null && award.title!.isNotEmpty) {
          graphics.drawString(
            award.title!,
            mainSubHeaderFont,
            brush: PdfSolidBrush(mainHeaderColor),
            bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 12),
          );
          mainY += 13;
        }

        // Issuer and date
        String issuerDate = '';
        if (award.issuer != null && award.issuer!.isNotEmpty) {
          issuerDate = award.issuer!;
        }
        if (award.month != null && award.year != null) {
          if (issuerDate.isNotEmpty) issuerDate += ' | ';
          issuerDate += '${award.month} ${award.year}';
        }

        if (issuerDate.isNotEmpty) {
          graphics.drawString(
            issuerDate,
            mainDateFont,
            brush: PdfSolidBrush(jobTitleColor),
            bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 11),
          );
          mainY += 12;
        }
        // Description
        if (award.description != null && award.description!.isNotEmpty) {
          mainY = _drawWrappedText(
            graphics: graphics,
            text: award.description!,
            font: mainBodyFont,
            x: mainContentX,
            y: mainY,
            maxWidth: mainContentWidth,
            lineHeight: 12,
            brush: PdfSolidBrush(mainTextColor),
          );
        }
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
        sidebarSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 15),
      );
      mainY += 10;

      for (var project in projectsList) {
        checkMainPageBreak(60);
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;

        // Project name
        if (project.name != null && project.name!.isNotEmpty) {
          String projectTitle = project.name!;
          if (project.year != null && project.year!.isNotEmpty) {
            projectTitle += ' (${project.year})';
          }

          graphics.drawString(
            projectTitle,
            sidebarSectionFont,
            brush: PdfSolidBrush(mainHeaderColor),
            bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 12),
          );
          mainY += 13;
        }

        // Role
        if (project.role != null && project.role!.isNotEmpty) {
          graphics.drawString(
            project.role!,
            mainDateFont,
            brush: PdfSolidBrush(jobTitleColor),
            bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 11),
          );
          mainY += 12;
        }
        // Technologies
        if (project.technologies != null && project.technologies!.isNotEmpty) {
          mainY = _drawWrappedText(
            graphics: graphics,
            text: 'Technologies: ${project.technologies}',
            font: mainBodyFont,
            x: mainContentX,
            y: mainY,
            maxWidth: mainContentWidth,
            lineHeight: 12,
            brush: PdfSolidBrush(mainTextColor),
          );
          mainY += 3;
        }

        // Description
        if (project.description != null && project.description!.isNotEmpty) {
          mainY = _drawWrappedText(
            graphics: graphics,
            text: project.description!,
            font: mainBodyFont,
            x: mainContentX,
            y: mainY,
            maxWidth: mainContentWidth,
            lineHeight: 12,
            brush: PdfSolidBrush(mainTextColor),
          );
        }
        mainY += 2;
      }
    }
    mainY += 5;

    // -- Hobbies Section --
    if (hobbiesList.isNotEmpty) {
      checkMainPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(mainPageIndex);
      graphics = page.graphics;

      graphics.drawString(
        'HOBBIES',
        sidebarSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 15),
      );
      mainY += 18;

      final double hobbyColumnWidth = mainContentWidth / 2;
      for (int i = 0; i < hobbiesList.length; i++) {
        checkMainPageBreak(20);
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;
        final hobby = hobbiesList[i];
        final xPos = (i % 2 == 0) ? mainContentX : mainContentX + hobbyColumnWidth;

        // Draw bullet
        graphics.drawString(
          '•',
          mainBodyFont,
          brush: PdfSolidBrush(mainTextColor),
          bounds: Rect.fromLTWH(xPos, mainY, 10, 12),
        );

        // Draw hobby name
        _drawWrappedText(
          graphics: graphics,
          text: hobby.name,
          font: mainBodyFont,
          x: xPos + 10,
          y: mainY,
          maxWidth: hobbyColumnWidth - 15,
          lineHeight: 12,
          brush: PdfSolidBrush(mainTextColor),
        );

        if (i % 2 != 0 || i == hobbiesList.length - 1) {
          mainY += 15;
        }
      }
    }
    mainY += 10;

    // -- References Section --
    if (referencesList.isNotEmpty) {
      checkMainPageBreak(50, isSectionHeader: true);
      page = getPageAtIndex(mainPageIndex);
      graphics = page.graphics;

      graphics.drawString(
        'REFERENCES',
        sidebarSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 15),
      );
      mainY += 18;

      for (var ref in referencesList) {
        checkMainPageBreak(60);
        page = getPageAtIndex(mainPageIndex);
        graphics = page.graphics;
        
        graphics.drawString(
          ref.name!,
          mainSubHeaderFont,
          brush: PdfSolidBrush(mainHeaderColor),
          bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 12),
        );
        mainY += 13;
        graphics.drawString(
          ref.company!,
          mainDateFont,
          brush: PdfSolidBrush(jobTitleColor),
          bounds: Rect.fromLTWH(mainContentX, mainY, mainContentWidth, 11),
        );
        mainY += 12;

        String contactInfo = '';
        if (ref.phone != null && ref.phone!.isNotEmpty) {
          contactInfo += ref.phone!;
        }
        if (ref.email != null && ref.email!.isNotEmpty) {
          if (contactInfo.isNotEmpty) contactInfo += ' | ';
          contactInfo += ref.email!;
        }
        mainY = _drawWrappedText(
          font: mainBodyFont,
          brush: PdfSolidBrush(mainTextColor),
          graphics: graphics,
          text: contactInfo,
          x: mainContentX,
          y: mainY,
          maxWidth: mainContentWidth,
          lineHeight: 12,
        );
      }
    }

    final List<int> bytes = await document.save();
    document.dispose();
    return Uint8List.fromList(bytes);
  }

  // Helper method to draw rounded rectangle
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
    PdfBrush? brush,
  }) {
    if (text.isEmpty) return y;

    final words = text.split(' ');
    String currentLine = '';
    double currentY = y;

    for (int i = 0; i < words.length; i++) {
      final testLine = currentLine.isEmpty ? words[i] : '$currentLine ${words[i]}';
      final testWidth = font.measureString(testLine).width;

      if (testWidth > maxWidth && currentLine.isNotEmpty) {
        graphics.drawString(
          currentLine,
          font,
          bounds: Rect.fromLTWH(x, currentY, maxWidth, lineHeight),
          format: PdfStringFormat(alignment: alignment),
          brush: brush ?? PdfBrushes.black,
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
        brush: brush ?? PdfBrushes.black,
      );
      currentY += lineHeight;
    }

    return currentY;
  }

  double _calculateWrappedTextHeight({
    required String text,
    required PdfFont font,
    required double maxWidth,
    required double lineHeight,
  }) {
    if (text.isEmpty) return 0;

    final words = text.split(' ');
    String currentLine = '';
    double totalHeight = 0;

    for (int i = 0; i < words.length; i++) {
      final testLine = currentLine.isEmpty ? words[i] : '$currentLine ${words[i]}';
      final testWidth = font.measureString(testLine).width;

      if (testWidth > maxWidth && currentLine.isNotEmpty) {
        totalHeight += lineHeight;
        currentLine = words[i];
      } else {
        currentLine = testLine;
      }
    }

    if (currentLine.isNotEmpty) {
      totalHeight += lineHeight;
    }

    return totalHeight;
  }
}
