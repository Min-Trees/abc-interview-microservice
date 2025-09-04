package com.abc.career_service.mapper;

import com.abc.career_service.dto.request.CareerPreferenceRequest;
import com.abc.career_service.dto.response.CareerPreferenceResponse;
import com.abc.career_service.entity.CareerPreference;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface CareerPreferenceMapper {
    CareerPreference toEntity(CareerPreferenceRequest request);

    CareerPreferenceResponse toResponse(CareerPreference preference);

    void updateEntityFromRequest(CareerPreferenceRequest request,
                                 @MappingTarget CareerPreference preference);
}