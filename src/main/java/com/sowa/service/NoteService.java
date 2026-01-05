package com.sowa.service;

import com.sowa.dto.NoteCreateDTO;
import com.sowa.dto.NoteUpdateDTO;
import com.sowa.exception.ResourceNotFoundException;
import com.sowa.exception.UnauthorizedAccessException;
import com.sowa.model.Note;
import com.sowa.model.User;
import com.sowa.repository.NoteRepository;
import com.sowa.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NoteService {
    
    @Autowired
    private NoteRepository noteRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    private Long getCurrentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw new UnauthorizedAccessException("User not authenticated");
        }
        
        UserDetails userDetails = (UserDetails) auth.getPrincipal();
        // Get user from database to get ID
        User user = userRepository.findByUsername(userDetails.getUsername())
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return user.getId();
    }
    
    public Note createNote(NoteCreateDTO dto) {
        Long userId = getCurrentUserId();
        
        Note note = new Note();
        note.setUserId(userId);
        note.setTitle(dto.getTitle());
        note.setDescription(dto.getDescription());
        note.setStatus(dto.getStatus());
        
        return noteRepository.save(note);
    }
    
    public List<Note> getUserNotes() {
        Long userId = getCurrentUserId();
        return noteRepository.findByUserId(userId);
    }
    
    public Note getNoteById(Long id) {
        Long userId = getCurrentUserId();
        return noteRepository.findByIdAndUserId(id, userId)
            .orElseThrow(() -> new ResourceNotFoundException("Note not found"));
    }
    
    public Note updateNote(Long id, NoteUpdateDTO dto) {
        Long userId = getCurrentUserId();
        
        Note note = noteRepository.findByIdAndUserId(id, userId)
            .orElseThrow(() -> new ResourceNotFoundException("Note not found"));
        
        if (dto.getTitle() != null) {
            note.setTitle(dto.getTitle());
        }
        if (dto.getDescription() != null) {
            note.setDescription(dto.getDescription());
        }
        if (dto.getStatus() != null) {
            note.setStatus(dto.getStatus());
        }
        
        return noteRepository.save(note);
    }
    
    public void deleteNote(Long id) {
        Long userId = getCurrentUserId();
        
        int deleted = noteRepository.deleteByIdAndUserId(userId, id);
        if (deleted == 0) {
            throw new ResourceNotFoundException("Note not found");
        }
    }
    
    public List<Note> searchNotes(String query) {
        Long userId = getCurrentUserId();
        // Using prepared statement to prevent SQL injection
        return noteRepository.searchByUserAndTitle(userId, "%" + query + "%");
    }
}
