package com.sowa.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class NoteUpdateDTO {
    
    @Size(max = 255, message = "Title cannot exceed 255 characters")
    private String title;
    
    @Size(max = 5000, message = "Description cannot exceed 5000 characters")
    private String description;
    
    @Size(max = 50, message = "Status cannot exceed 50 characters")
    private String status;
}
