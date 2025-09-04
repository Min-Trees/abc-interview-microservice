package com.abc.career_service.service;

import com.abc.career_service.dto.request.CareerPreferenceRequest;
import com.abc.career_service.dto.response.CareerPreferenceResponse;
import com.abc.career_service.entity.CareerPreference;
import com.abc.career_service.mapper.CareerPreferenceMapper;
import com.abc.career_service.repository.CareerPreferenceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
@RequiredArgsConstructor
@Service
public class CareerService {

    private final CareerPreferenceMapper careerPreferenceMapper;
    private final CareerPreferenceRepository careerPreferenceRepository;

    public CareerPreferenceResponse createCareer (CareerPreferenceRequest request){
        CareerPreference careerPreference = careerPreferenceMapper.toEntity(request);
        careerPreference.setCreatedAt(LocalDateTime.now());
        careerPreference.setUpdatedAt(LocalDateTime.now());
        return careerPreferenceMapper.toResponse(careerPreferenceRepository.save(careerPreference));
    }

    public CareerPreferenceResponse updateCareer (Long careerId ,CareerPreferenceRequest request){
        CareerPreference careerPreference = careerPreferenceRepository.findById(careerId).orElse(null);
        assert careerPreference != null;
        careerPreference.setUpdatedAt(LocalDateTime.now());
        careerPreferenceMapper.updateEntityFromRequest(request,careerPreference);
        careerPreferenceRepository.save(careerPreference);
        return careerPreferenceMapper.toResponse(careerPreference);
    }

    public CareerPreferenceResponse getCareerById (Long careerId){
        CareerPreference careerPreference = careerPreferenceRepository.findById(careerId)
                .orElse(null);
        assert careerPreference != null;
        return careerPreferenceMapper.toResponse(careerPreference);
    }

    public Page<CareerPreferenceResponse> getCareerByUserId (Long userId, Pageable pageable){
        Page<CareerPreference> careerPreferencePage = careerPreferenceRepository.findByUserId(userId, pageable);
        return careerPreferencePage.map(careerPreferenceMapper::toResponse);
    }
}
