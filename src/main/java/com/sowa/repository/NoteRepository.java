package com.sowa.repository;

import com.sowa.model.Note;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface NoteRepository extends JpaRepository<Note, Long> {
    
    List<Note> findByUserId(Long userId);
    
    Optional<Note> findByIdAndUserId(Long id, Long userId);
    
    // Prepared statement query to prevent SQL injection
    @Query(value = "SELECT * FROM notes WHERE user_id = ?1 AND title LIKE ?2 ORDER BY created_at DESC", 
           nativeQuery = true)
    List<Note> searchByUserAndTitle(Long userId, String titlePattern);
    
    @Modifying
    @Query(value = "DELETE FROM notes WHERE user_id = ?1 AND id = ?2", nativeQuery = true)
    int deleteByIdAndUserId(Long userId, Long id);
}
