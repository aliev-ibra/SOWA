package com.sowa.controller;

import com.sowa.dto.NoteCreateDTO;
import com.sowa.dto.NoteUpdateDTO;
import com.sowa.model.Note;
import com.sowa.service.NoteService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notes")
@Validated
public class NoteController {
    
    @Autowired
    private NoteService noteService;
    
    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Note> createNote(@Valid @RequestBody NoteCreateDTO dto) {
        Note note = noteService.createNote(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(note);
    }
    
    @GetMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<List<Note>> getAllNotes() {
        List<Note> notes = noteService.getUserNotes();
        return ResponseEntity.ok(notes);
    }
    
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Note> getNoteById(@PathVariable Long id) {
        Note note = noteService.getNoteById(id);
        return ResponseEntity.ok(note);
    }
    
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Note> updateNote(
            @PathVariable Long id,
            @Valid @RequestBody NoteUpdateDTO dto) {
        Note note = noteService.updateNote(id, dto);
        return ResponseEntity.ok(note);
    }
    
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Void> deleteNote(@PathVariable Long id) {
        noteService.deleteNote(id);
        return ResponseEntity.noContent().build();
    }
    
    @GetMapping("/search")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<List<Note>> searchNotes(@RequestParam String q) {
        List<Note> notes = noteService.searchNotes(q);
        return ResponseEntity.ok(notes);
    }
}
