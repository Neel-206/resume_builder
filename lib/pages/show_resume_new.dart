import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resume_builder/pages/pdf_preview_page.dart';
import 'package:resume_builder/services/resume_storage.dart';
import 'package:intl/intl.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';

/// ShowResume Page - Displays saved resumes in a modern grid layout
/// Features: Glassmorphism design, smooth animations, and intuitive UX
class ShowResume extends StatefulWidget {
  const ShowResume({super.key});

  @override
  State<ShowResume> createState() => _ShowResumeState();
}

class _ShowResumeState extends State<ShowResume>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _resumes = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  Animation<double>?
  _fadeAnimation; // Nullable to prevent LateInitializationError

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // Initialize fade animation
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadResumes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Loads all saved resumes from storage
  Future<void> _loadResumes() async {
    try {
      final resumes = await ResumeStorage.getAllResumes();
      if (mounted) {
        setState(() {
          _resumes = resumes;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error loading resumes: $e', isError: true);
      }
    }
  }

  /// Deletes a resume with confirmation
  Future<void> _deleteResume(Map<String, dynamic> resume) async {
    try {
      await ResumeStorage.deleteResume(resume['filePath']);
      await _loadResumes();
      if (mounted) {
        _showSnackBar('Resume deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error deleting resume: $e', isError: true);
      }
    }
  }

  /// Helper method to show snackbar messages
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _buildGradientBackground(),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              _buildHeader(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.03),
              _buildSubtitle(screenWidth),
              SizedBox(height: screenHeight * 0.03),
              Expanded(child: _buildResumeGrid(screenWidth)),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds gradient background
  BoxDecoration _buildGradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xff5f56ee), Color(0xffe4d8fd), Color(0xff9b8fff)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  /// Builds the main header with title and decorative line
  Widget _buildHeader(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ' RESUME LIBRARY',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.075,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        Container(
          width: screenWidth * 0.3,
          height: 4,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xffffb300),
                Color.fromARGB(255, 255, 255, 255),
                Color(0xffffb300),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  /// Builds subtitle text
  Widget _buildSubtitle(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Text(
        'Find all your downloaded resumes right here, ready when you need them',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  /// Builds the main resume grid or empty state
  Widget _buildResumeGrid(double screenWidth) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_resumes.isEmpty) {
      return _buildEmptyState(screenWidth);
    }

    // Check if animation is initialized before using FadeTransition
    if (_fadeAnimation == null) {
      return _buildGridView(screenWidth);
    }

    return FadeTransition(
      opacity: _fadeAnimation!,
      child: _buildGridView(screenWidth),
    );
  }

  /// Builds the grid view widget
  Widget _buildGridView(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.7,
        ),
        itemCount: _resumes.length,
        itemBuilder: (context, index) {
          return _buildResumeCard(_resumes[index], index);
        },
      ),
    );
  }

  /// Builds loading indicator
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading resumes...',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds empty state when no resumes exist
  Widget _buildEmptyState(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.description_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No Resumes Yet',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Create your first resume and\nit will appear here',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: screenWidth * 0.04,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds individual resume card with glassmorphic effect
  Widget _buildResumeCard(Map<String, dynamic> resume, int index) {
    final file = File(resume['filePath']);
    final dateCreated = DateTime.parse(resume['createdAt']);
    final formattedDate = DateFormat('MMM d, y').format(dateCreated);
    final formattedTime = DateFormat('h:mm a').format(dateCreated);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: InkWell(
        onTap: () => _openResume(file, resume),
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _buildThumbnail(resume),
                ),
              ),
              _buildCardFooter(resume, formattedDate, formattedTime),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds PDF thumbnail with delete button - FIXED: Prevents overflow by constraining properly
  Widget _buildThumbnail(Map<String, dynamic> resume) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  // PDF Thumbnail - Properly constrained to prevent overflow
                  Positioned.fill(
                    child: ClipRect(
                      child: OverflowBox(
                        maxWidth: constraints.maxWidth,
                        maxHeight: constraints.maxHeight,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: PdfThumbnail.fromFile(
                              resume['filePath'],
                              currentPage: 1,
                              backgroundColor: Colors.white,
                              loadingIndicator: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white.withOpacity(0.7),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Delete Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildDeleteButton(resume),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds delete button with glassmorphic effect
  Widget _buildDeleteButton(Map<String, dynamic> resume) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDeleteDialog(resume),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade600],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.9),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.delete_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  /// Builds card footer with name and date
  Widget _buildCardFooter(
    Map<String, dynamic> resume,
    String formattedDate,
    String formattedTime,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resume['templateName'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 13,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '$formattedDate • $formattedTime',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Opens resume in preview page
  void _openResume(File file, Map<String, dynamic> resume) {
    if (file.existsSync()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfPreviewPage(
            path: resume['filePath'],
            templateName: resume['templateName'],
          ),
        ),
      );
    } else {
      _showSnackBar('Resume file not found', isError: true);
      _loadResumes();
    }
  }

  /// Shows delete confirmation dialog
  void _showDeleteDialog(Map<String, dynamic> resume) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Delete Resume?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete "${resume['templateName']}". This action cannot be undone.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteResume(resume);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
