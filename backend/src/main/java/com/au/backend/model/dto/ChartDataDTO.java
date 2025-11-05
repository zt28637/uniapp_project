package com.au.backend.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class ChartDataDTO {
    // X轴：用户标识
    private List<String> categories;
    // Y轴：使用次数
    private List<Integer> values;
}
