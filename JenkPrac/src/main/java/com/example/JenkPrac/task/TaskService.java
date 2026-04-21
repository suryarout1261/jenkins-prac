package com.example.JenkPrac.task;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class TaskService {

    private final Map<Long, Task> tasks = new ConcurrentHashMap<>();
    private final AtomicLong idCounter = new AtomicLong(0);

    public List<Task> getAll() {
        List<Task> allTasks = new ArrayList<>(tasks.values());
        allTasks.sort(Comparator.comparing(Task::getId));
        return allTasks;
    }

    public Task getById(Long id) {
        Task task = tasks.get(id);
        if (task == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Task not found for id " + id);
        }
        return task;
    }

    public Task create(TaskRequest request) {
        Long id = idCounter.incrementAndGet();
        Task task = new Task(
                id,
                request.getTitle(),
                request.getDescription(),
                Boolean.TRUE.equals(request.getCompleted())
        );
        tasks.put(id, task);
        return task;
    }

    public Task update(Long id, TaskRequest request) {
        Task existing = tasks.get(id);
        if (existing == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Task not found for id " + id);
        }

        existing.setTitle(request.getTitle());
        existing.setDescription(request.getDescription());
        existing.setCompleted(Boolean.TRUE.equals(request.getCompleted()));
        return existing;
    }

    public void delete(Long id) {
        Task removed = tasks.remove(id);
        if (removed == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Task not found for id " + id);
        }
    }
}
