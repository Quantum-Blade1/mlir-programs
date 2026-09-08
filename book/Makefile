# ==============================================================================
# Makefile for Principles of Distributed Quantum Compilers
# Author: Krish Kumar Sharma
# ==============================================================================

TARGET = main
PDF = $(TARGET).pdf
LATEXMK = latexmk
PDFLATEX = pdflatex
BIBTEX = bibtex

.PHONY: all clean cleanall watch view overleaf-zip

all: $(PDF)

# Primary build using latexmk (handles multi-pass references, bibtex, glossaries automatically)
$(PDF): $(TARGET).tex preamble.tex references.bib $(wildcard chapters/*.tex) $(wildcard frontmatter/*.tex)
	@echo "==> Compiling Master Treatise: $(TARGET).pdf..."
	@which $(LATEXMK) > /dev/null 2>&1 && $(LATEXMK) -pdf -interaction=nonstopmode -synctex=1 $(TARGET).tex || \
	( \
		echo "==> $(LATEXMK) not found. Falling back to multi-pass $(PDFLATEX)..."; \
		$(PDFLATEX) -interaction=nonstopmode $(TARGET).tex && \
		$(BIBTEX) $(TARGET) && \
		$(PDFLATEX) -interaction=nonstopmode $(TARGET).tex && \
		$(PDFLATEX) -interaction=nonstopmode $(TARGET).tex \
	)
	@echo "==> Successfully compiled $(PDF)!"

# Continuous compilation / live watch
watch:
	@$(LATEXMK) -pvc -pdf -interaction=nonstopmode $(TARGET).tex

# Clean auxiliary build artifacts
clean:
	@rm -f *.aux *.bbl *.bcf *.blg *.dvi *.fdb_latexmk *.fls *.log *.out *.run.xml *.synctex.gz *.toc *.lof *.lot
	@rm -f chapters/*.aux frontmatter/*.aux

# Deep clean including the generated PDF
cleanall: clean
	@rm -f $(PDF) book_overleaf.zip

# Package for one-click upload to Overleaf
overleaf-zip: clean
	@echo "==> Creating Overleaf upload package: book_overleaf.zip..."
	@zip -r book_overleaf.zip main.tex preamble.tex references.bib Makefile README.md chapters/ frontmatter/
	@echo "==> book_overleaf.zip created successfully!"
