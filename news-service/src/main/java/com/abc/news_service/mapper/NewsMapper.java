package com.abc.news_service.mapper;

import com.abc.news_service.dto.*;
import com.abc.news_service.entity.News;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface NewsMapper {
    News toEntity(NewsRequest req);
    NewsResponse toResponse(News entity);
}
