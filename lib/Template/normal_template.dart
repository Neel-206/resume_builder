import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:resume_builder/models/resume_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class NormalTemplate {
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

    // --- Define Colors ---
    final mainHeaderColor = PdfColor(0, 0, 0);
    final sectionHeaderColor = PdfColor(0, 0, 0);
    final textColor = PdfColor(33, 33, 33);
    final accentColor = PdfColor(70, 70, 70);

    // --- Define Fonts ---
    final PdfFont nameFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      24,
      style: PdfFontStyle.bold,
    );
    final PdfFont labelFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      11,
      style: PdfFontStyle.regular,
    );
    final PdfFont contactFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final PdfFont phoneFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      10,
      style: PdfFontStyle.regular,
    );
    final PdfFont contactLabelFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      9,
      style: PdfFontStyle.bold,
    );
    final PdfFont sidebarSubHeaderFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      10,
      style: PdfFontStyle.bold,
    );
    final PdfFont sidebarBodyFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      10,
    );
    final PdfFont mainSectionFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      14,
      style: PdfFontStyle.bold,
    );
    final PdfFont mainSubHeaderFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      11,
      style: PdfFontStyle.bold,
    );
    final PdfFont mainBodyFont = PdfStandardFont(PdfFontFamily.helvetica, 10);

    // --- Layout Settings ---
    final double contentPadding = 0;
    final double contentX = contentPadding;
    final double contentWidth = pageSize.width - (contentPadding * 2);
    double currentY = contentPadding;

    // Enhanced page break check with section header protection
    void checkPageBreak(double neededSpace, {bool isSectionHeader = false}) {
      // If it's a section header, ensure minimum space for header + first line of content
      double requiredSpace = isSectionHeader ? neededSpace + 50 : neededSpace;

      if (currentY + requiredSpace > pageSize.height - contentPadding) {
        page = document.pages.add();
        graphics = page.graphics;
        currentY = contentPadding;
      }
    }

    // --- HEADER ---
    final double headerLeftWidth = contentWidth * 0.55;
    final double headerRightWidth = contentWidth * 0.45;
    final double headerRightX = contentX + headerLeftWidth;

    double leftY = currentY;
    double rightY = currentY;

    // LEFT SIDE: Name
    final String fullName =
        '${profileData?.firstName ?? ''} ${profileData?.lastName ?? ''}'.trim();

    if (fullName.isNotEmpty) {
      graphics.drawString(
        fullName,
        nameFont,
        brush: PdfSolidBrush(mainHeaderColor),
        bounds: Rect.fromLTWH(
          contentX,
          leftY,
          headerLeftWidth,
          nameFont.height,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
      );
      leftY += nameFont.height + 6;
    }

    // RIGHT SIDE: Phone
    final String phone = profileData?.phone ?? '';
    if (phone.isNotEmpty) {
      final double phoneLabelWidth = contactLabelFont
          .measureString('Phone: ')
          .width;
      final double phoneValueWidth = phoneFont.measureString(phone).width;
      final double phoneX =
          headerRightX + headerRightWidth - phoneValueWidth - phoneLabelWidth;

      graphics.drawString(
        'Phone: ',
        contactLabelFont,
        brush: PdfSolidBrush(accentColor),
        bounds: Rect.fromLTWH(
          phoneX,
          rightY,
          phoneLabelWidth,
          phoneFont.height,
        ),
      );

      graphics.drawString(
        phone,
        phoneFont,
        brush: PdfSolidBrush(textColor),
        bounds: Rect.fromLTWH(
          phoneX + phoneLabelWidth,
          rightY,
          phoneValueWidth,
          phoneFont.height,
        ),
      );
      rightY += phoneFont.height + 6;
    }

    // --- Second Header Row: Job Title and Email ---
    currentY = leftY > rightY ? leftY : rightY;
    leftY = currentY;
    rightY = currentY;

    // Job Title on the left
    final String jobTitle = profileData?.jobTitle ?? '';
    if (jobTitle.isNotEmpty) {
      graphics.drawString(
        jobTitle,
        labelFont,
        brush: PdfSolidBrush(accentColor),
        bounds: Rect.fromLTWH(
          contentX,
          leftY,
          headerLeftWidth,
          labelFont.height,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
      );
      leftY += labelFont.height + 4;
    }

    // Email on the right
    final String email = profileData?.email ?? '';
    if (email.isNotEmpty) {
      final double emailLabelWidth = contactLabelFont
          .measureString('Email: ')
          .width;
      final double emailValueWidth = contactFont.measureString(email).width;
      final double emailX =
          headerRightX + headerRightWidth - emailValueWidth - emailLabelWidth;

      graphics.drawString(
        'Email: ',
        contactLabelFont,
        brush: PdfSolidBrush(accentColor),
        bounds: Rect.fromLTWH(
          emailX,
          rightY,
          emailLabelWidth,
          contactFont.height,
        ),
      );

      graphics.drawString(
        email,
        contactFont,
        brush: PdfSolidBrush(textColor),
        bounds: Rect.fromLTWH(
          emailX + emailLabelWidth,
          rightY,
          emailValueWidth,
          contactFont.height,
        ),
      );
      rightY += contactFont.height + 4;
    }

    currentY = leftY > rightY ? leftY : rightY;
    currentY += 12;

    // Header divider line
    graphics.drawLine(
      PdfPen(PdfColor(0, 0, 0), width: 1.5),
      Offset(contentX, currentY),
      Offset(contentX + contentWidth, currentY),
    );
    currentY += 15;

    // --- OBJECTIVE SECTION ---
    if (aboutData?.aboutText != null && aboutData!.aboutText!.isNotEmpty) {
      checkPageBreak(60, isSectionHeader: true);
      graphics = page.graphics;

      graphics.drawString(
        'OBJECTIVE',
        mainSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(contentX, currentY, contentWidth, 20),
      );
      currentY += 22;

      currentY = _drawWrappedText(
        graphics: graphics,
        text: aboutData.aboutText!,
        font: mainBodyFont,
        x: contentX,
        y: currentY,
        maxWidth: contentWidth,
        alignment: PdfTextAlignment.justify,
        lineHeight: 14,
      );
      currentY += 18;

      graphics.drawLine(
        PdfPen(PdfColor(200, 200, 200), width: 0.5),
        Offset(contentX, currentY),
        Offset(contentX + contentWidth, currentY),
      );
      currentY += 15;
    }

    // --- EDUCATION SECTION ---
    if (educationList.isNotEmpty) {
      checkPageBreak(60, isSectionHeader: true);
      graphics = page.graphics;

      graphics.drawString(
        'EDUCATION',
        mainSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(contentX, currentY, contentWidth, 20),
      );
      currentY += 22;

      for (var edu in educationList) {
        checkPageBreak(70);
        graphics = page.graphics;

        if (edu.degree != null && edu.degree!.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: edu.degree!,
            font: sidebarSubHeaderFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
            alignment: PdfTextAlignment.left,
          );
        }

        String schoolInfo = edu.school ?? '';
        if (edu.marks != null && edu.marks!.isNotEmpty) {
          schoolInfo += ' | ${edu.marks!}';
        }
        if (schoolInfo.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: schoolInfo,
            font: sidebarBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
            alignment: PdfTextAlignment.left,
          );
        }

        String yearRange = '';
        if (edu.fromYear != null && edu.fromYear!.isNotEmpty) {
          yearRange = edu.fromYear!;
          if (edu.toYear != null && edu.toYear!.isNotEmpty) {
            yearRange += ' - ${edu.toYear!}';
          }
        }
        if (yearRange.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: yearRange,
            font: sidebarBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
            alignment: PdfTextAlignment.left,
          );
        }

        String location = '';
        if (edu.place != null && edu.place!.isNotEmpty) {
          location = edu.place!;
          if (edu.country != null && edu.country!.isNotEmpty) {
            location += ', ${edu.country!}';
          }
        }
        if (location.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: location,
            font: sidebarBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
            alignment: PdfTextAlignment.left,
          );
        }

        currentY += 12;
      }

      currentY += 3;
      graphics.drawLine(
        PdfPen(PdfColor(200, 200, 200), width: 0.5),
        Offset(contentX, currentY),
        Offset(contentX + contentWidth, currentY),
      );
      currentY += 15;
    }

    // --- TECHNICAL SKILLS SECTION ---
    if (skillsList.isNotEmpty) {
      checkPageBreak(60, isSectionHeader: true);
      graphics = page.graphics;

      graphics.drawString(
        'TECHNICAL SKILLS',
        mainSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(contentX, currentY, contentWidth, 20),
      );
      currentY += 22;

      final double skillNameWidth = contentWidth * 0.50;
      final double proficiencyBarX = contentX + skillNameWidth + 15;
      final double proficiencyBarWidth = contentWidth * 0.32;
      final double proficiencyLabelX =
          proficiencyBarX + proficiencyBarWidth + 10;

      for (var skill in skillsList) {
        checkPageBreak(22);
        graphics = page.graphics;

        graphics.drawString(
          '• ${skill.name}',
          sidebarBodyFont,
          brush: PdfSolidBrush(textColor),
          bounds: Rect.fromLTWH(contentX, currentY + 1, skillNameWidth, 13),
        );

        if (skill.proficiency.isNotEmpty) {
          _drawRoundedRectangle(
            graphics,
            proficiencyBarX,
            currentY + 3,
            proficiencyBarWidth,
            9,
            4.5,
            PdfSolidBrush(PdfColor(230, 230, 230)),
            null,
          );

          double fillPercentage = _getProficiencyPercentage(skill.proficiency);
          double filledWidth = proficiencyBarWidth * fillPercentage;

          _drawRoundedRectangle(
            graphics,
            proficiencyBarX,
            currentY + 3,
            filledWidth,
            9,
            4.5,
            PdfSolidBrush(PdfColor(40, 40, 40)),
            null,
          );

          graphics.drawString(
            skill.proficiency.toUpperCase(),
            PdfStandardFont(
              PdfFontFamily.helvetica,
              8,
              style: PdfFontStyle.bold,
            ),
            brush: PdfSolidBrush(PdfColor(100, 100, 100)),
            bounds: Rect.fromLTWH(
              proficiencyLabelX,
              currentY + 2,
              contentWidth - proficiencyLabelX + contentX,
              13,
            ),
          );
        }

        currentY += 16;
      }

      currentY += 3;
      graphics.drawLine(
        PdfPen(PdfColor(200, 200, 200), width: 0.5),
        Offset(contentX, currentY),
        Offset(contentX + contentWidth, currentY),
      );
      currentY += 15;
    }

    // --- ACADEMIC PROJECTS SECTION ---
    if (projectsList.isNotEmpty) {
      checkPageBreak(60, isSectionHeader: true);
      graphics = page.graphics;

      graphics.drawString(
        'ACADEMIC PROJECTS',
        mainSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(contentX, currentY, contentWidth, 20),
      );
      currentY += 22;

      for (var project in projectsList) {
        checkPageBreak(75);
        graphics = page.graphics;

        String projectTitle = project.name ?? '';
        if (project.year != null && project.year!.isNotEmpty) {
          projectTitle += ' (${project.year!})';
        }

        if (projectTitle.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: projectTitle,
            font: sidebarSubHeaderFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
          );
        }

        if (project.role != null && project.role!.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: 'Role: ${project.role!}',
            font: mainBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 14,
          );
        }

        if (project.technologies != null && project.technologies!.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: 'Technologies: ${project.technologies!}',
            font: mainBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 14,
          );
        }

        if (project.description != null && project.description!.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: project.description!,
            font: mainBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 14,
            alignment: PdfTextAlignment.justify,
          );
        }

        currentY += 12;
      }

      currentY += 3;
      graphics.drawLine(
        PdfPen(PdfColor(200, 200, 200), width: 0.5),
        Offset(contentX, currentY),
        Offset(contentX + contentWidth, currentY),
      );
      currentY += 15;
    }

    // --- EXPERIENCE SECTION ---
    checkPageBreak(60, isSectionHeader: true);
    graphics = page.graphics;

    graphics.drawString(
      'EXPERIENCE',
      mainSectionFont,
      brush: PdfSolidBrush(sectionHeaderColor),
      bounds: Rect.fromLTWH(contentX, currentY, contentWidth, 20),
    );
    currentY += 22;

    if (experienceList.isEmpty) {
      checkPageBreak(75);
      graphics = page.graphics;

      graphics.drawString(
        'Fresher',
        mainSubHeaderFont,
        brush: PdfSolidBrush(textColor),
        bounds: Rect.fromLTWH(
          contentX,
          currentY,
          contentWidth,
          mainSubHeaderFont.height, 
        ),
        format: PdfStringFormat(
          alignment: PdfTextAlignment.left,
        ),
      );
      currentY += mainSubHeaderFont.height + 2;

      currentY += 10;
      graphics.drawLine(
        PdfPen(PdfColor(200, 200, 200), width: 0.5),
        Offset(contentX, currentY),
        Offset(contentX + contentWidth, currentY),
      );
      currentY += 15;
    } else {
      for (var exp in experienceList) {
        checkPageBreak(75);
        graphics = page.graphics;

        if (exp.company != null && exp.company!.isNotEmpty) {
          graphics.drawString(
            exp.company!,
            mainSubHeaderFont,
            brush: PdfSolidBrush(textColor),
            bounds: Rect.fromLTWH(
              contentX,
              currentY,
              contentWidth,
              mainSubHeaderFont.height,
            ),
            format: PdfStringFormat(alignment: PdfTextAlignment.left),
          );
          currentY += mainSubHeaderFont.height + 2;
        }

        if (exp.position != null && exp.position!.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: exp.position!,
            font: sidebarBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
          );
        }

        String dateRange = '';
        if (exp.fromMonth != null && exp.fromYear != null) {
          dateRange = '${exp.fromMonth} ${exp.fromYear}';
          if (exp.toMonth != null && exp.toYear != null) {
            dateRange += ' - ${exp.toMonth} ${exp.toYear}';
          }
        }
        if (dateRange.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: dateRange,
            font: mainBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
          );
        }

        if (exp.description != null && exp.description!.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: exp.description!,
            font: mainBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 14,
            alignment: PdfTextAlignment.justify,
          );
        }

        currentY += 12;
      }

      currentY += 3;
      graphics.drawLine(
        PdfPen(PdfColor(200, 200, 200), width: 0.5),
        Offset(contentX, currentY),
        Offset(contentX + contentWidth, currentY),
      );
      currentY += 15;
    }

    // --- LANGUAGE SECTION ---
    if (languagesList.isNotEmpty) {
      checkPageBreak(60, isSectionHeader: true);
      graphics = page.graphics;

      graphics.drawString(
        'LANGUAGES',
        mainSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(contentX, currentY, contentWidth, 20),
      );
      currentY += 22;

      final double columnWidth = (contentWidth - 20) / 2;
      int columnIndex = 0;
      double columnY = currentY;

      for (var lang in languagesList) {
        checkPageBreak(20);
        graphics = page.graphics;

        double xPos = contentX + (columnIndex * (columnWidth + 20));

        graphics.drawString(
          '• ${lang.name}',
          sidebarBodyFont,
          brush: PdfSolidBrush(textColor),
          bounds: Rect.fromLTWH(xPos, columnY, columnWidth, 13),
        );

        columnIndex++;
        if (columnIndex >= 2) {
          columnIndex = 0;
          columnY += 16;
        }
      }

      if (columnIndex > 0) {
        currentY = columnY + 16;
      } else {
        currentY = columnY;
      }

      currentY += 3;
      graphics.drawLine(
        PdfPen(PdfColor(200, 200, 200), width: 0.5),
        Offset(contentX, currentY),
        Offset(contentX + contentWidth, currentY),
      );
      currentY += 15;
    }

    // --- HOBBIES SECTION ---
    if (hobbiesList.isNotEmpty) {
      checkPageBreak(60, isSectionHeader: true);
      graphics = page.graphics;

      graphics.drawString(
        'HOBBIES',
        mainSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(contentX, currentY, contentWidth, 20),
      );
      currentY += 22;

      final double columnWidth = (contentWidth - 20) / 2;
      int columnIndex = 0;
      double columnY = currentY;

      for (var hobby in hobbiesList) {
        checkPageBreak(20);
        graphics = page.graphics;

        double xPos = contentX + (columnIndex * (columnWidth + 20));

        graphics.drawString(
          '• ${hobby.name}',
          sidebarBodyFont,
          brush: PdfSolidBrush(textColor),
          bounds: Rect.fromLTWH(xPos, columnY, columnWidth, 13),
        );

        columnIndex++;
        if (columnIndex >= 2) {
          columnIndex = 0;
          columnY += 16;
        }
      }

      if (columnIndex > 0) {
        currentY = columnY + 16;
      } else {
        currentY = columnY;
      }

      currentY += 3;
      graphics.drawLine(
        PdfPen(PdfColor(200, 200, 200), width: 0.5),
        Offset(contentX, currentY),
        Offset(contentX + contentWidth, currentY),
      );
      currentY += 15;
    }

    // --- AWARDS SECTION ---
    if (awardsList.isNotEmpty) {
      checkPageBreak(60, isSectionHeader: true);
      graphics = page.graphics;

      graphics.drawString(
        'AWARDS',
        mainSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(contentX, currentY, contentWidth, 20),
      );
      currentY += 22;

      for (var award in awardsList) {
        checkPageBreak(60);
        graphics = page.graphics;

        if (award.title != null && award.title!.isNotEmpty) {
          graphics.drawString(
            award.title!,
            mainSubHeaderFont,
            brush: PdfSolidBrush(textColor),
            bounds: Rect.fromLTWH(
              contentX,
              currentY,
              contentWidth,
              mainSubHeaderFont.height,
            ),
            format: PdfStringFormat(alignment: PdfTextAlignment.left),
          );
          currentY += mainSubHeaderFont.height + 2;
        }

        if (award.issuer != null && award.issuer!.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: award.issuer!,
            font: sidebarBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
          );
        }

        String awardDate = '';
        if (award.month != null && award.month!.isNotEmpty) {
          awardDate = award.month!;
          if (award.year != null && award.year!.isNotEmpty) {
            awardDate += ' ${award.year!}';
          }
        }
        if (awardDate.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: awardDate,
            font: sidebarBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
          );
        }

        if (award.description != null && award.description!.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: award.description!,
            font: mainBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 14,
            alignment: PdfTextAlignment.justify,
          );
        }

        currentY += 12;
      }

      currentY += 3;
      graphics.drawLine(
        PdfPen(PdfColor(200, 200, 200), width: 0.5),
        Offset(contentX, currentY),
        Offset(contentX + contentWidth, currentY),
      );
      currentY += 15;
    }

    // --- REFERENCES SECTION ---
    if (referencesList.isNotEmpty) {
      checkPageBreak(60, isSectionHeader: true);
      graphics = page.graphics;

      graphics.drawString(
        'REFERENCES',
        mainSectionFont,
        brush: PdfSolidBrush(sectionHeaderColor),
        bounds: Rect.fromLTWH(contentX, currentY, contentWidth, 20),
      );
      currentY += 22;

      for (var ref in referencesList) {
        checkPageBreak(70);
        graphics = page.graphics;

        if (ref.name != null && ref.name!.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: ref.name!,
            font: mainSubHeaderFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
          );
        }

        if (ref.company != null && ref.company!.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: ref.company!,
            font: sidebarBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
          );
        }

        if (ref.relationship != null && ref.relationship!.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: ref.relationship!,
            font: sidebarBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
          );
        }

        if (ref.phone != null && ref.phone!.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: 'Phone: ${ref.phone!}',
            font: mainBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
          );
        }

        if (ref.email != null && ref.email!.isNotEmpty) {
          currentY = _drawWrappedText(
            graphics: graphics,
            text: 'Email: ${ref.email!}',
            font: mainBodyFont,
            x: contentX,
            y: currentY,
            maxWidth: contentWidth,
            lineHeight: 13,
          );
        }

        currentY += 12;
      }
    }

    // Save and return
    final List<int> bytes = await document.save();
    document.dispose();
    return Uint8List.fromList(bytes);
  }

  double _getProficiencyPercentage(String proficiency) {
    final lowerProf = proficiency.toLowerCase().trim();

    if (lowerProf.contains('%')) {
      final numStr = lowerProf.replaceAll(RegExp(r'[^0-9]'), '');
      final num = int.tryParse(numStr);
      if (num != null) return (num / 100.0).clamp(0.0, 1.0);
    }

    switch (lowerProf) {
      case 'expert':
        return 1.00;
      case 'advanced':
        return 0.85;
      case 'proficient':
      case 'good':
        return 0.70;
      case 'intermediate':
      case 'moderate':
        return 0.55;
      case 'beginner':
      case 'basic':
        return 0.35;
      default:
        return 0.60;
    }
  }

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
    if (brush == null && pen == null) return;

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
