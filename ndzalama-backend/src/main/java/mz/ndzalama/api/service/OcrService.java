package mz.ndzalama.api.service;

import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

// Handles OCR extraction from uploaded images.
@Service
public class OcrService {

    // Extracts text from image using Tesseract OCR.
    public String extractText(MultipartFile file) {

        File tempFile = null;

        try {
            tempFile = File.createTempFile("ocr-", "-" + file.getOriginalFilename());
            file.transferTo(tempFile);

            BufferedImage image = ImageIO.read(tempFile);

            if (image == null) {
                throw new RuntimeException("Imagem inválida ou formato não suportado.");
            }

            Tesseract tesseract = new Tesseract();

            File tessDataFolder = new File("src/main/resources/tessdata");

            tesseract.setDatapath(
                    "C:/Users/Aristides Guilherme/Desktop/Ndzalama IA - VM/ndzalama-backend/src/main/resources/tessdata"
            );
            tesseract.setLanguage("por");

            return tesseract.doOCR(image);

        } catch (IOException | TesseractException e) {
            throw new RuntimeException("Erro ao processar OCR: " + e.getMessage());
        } finally {
            if (tempFile != null && tempFile.exists()) {
                tempFile.delete();
            }
        }
    }
}
