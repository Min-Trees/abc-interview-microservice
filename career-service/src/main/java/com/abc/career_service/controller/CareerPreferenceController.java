package com.abc.career_service.controller;

import com.abc.career_service.dto.request.CareerPreferenceRequest;
import com.abc.career_service.dto.response.CareerPreferenceResponse;
import com.abc.career_service.entity.CareerPreference;
import com.abc.career_service.service.CareerService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/career")
@RequiredArgsConstructor
public class CareerPreferenceController {
    private final CareerService careerService;
    @PostMapping
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public CareerPreferenceResponse createCareer (@RequestBody CareerPreferenceRequest request){

        return careerService.createCareer(request);
    }

    @PutMapping("/update/{careerId}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public CareerPreferenceResponse updateCareer(@PathVariable Long careerId, @RequestBody CareerPreferenceRequest request){
        return careerService.updateCareer(careerId, request);
    }

    @GetMapping("/{careerId:[0-9]+}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public CareerPreferenceResponse getCareerById(@PathVariable Long careerId){
        return careerService.getCareerById(careerId);
    }

    @GetMapping("/preferences/{userId}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public Page<CareerPreferenceResponse>  getCareerByUserId(@PathVariable Long userId, Pageable pageable){
        return careerService.getCareerByUserId(userId, pageable);
    }

    @DeleteMapping("/{careerId}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public void deleteCareer(@PathVariable Long careerId){
        careerService.deleteCareer(careerId);
    }
}
