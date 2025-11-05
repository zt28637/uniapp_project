package com.au.backend.controller;

import com.au.backend.model.base.ApiResponse;
import com.au.backend.model.dto.ChartDataDTO;
import com.au.backend.service.DashboardService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/dashboard")
@AllArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    //获取用户使用频率
    @RequestMapping("/getUserFrequency")
    public ApiResponse<ChartDataDTO> getUserFrequency() {
        return dashboardService.getUserFrequency();
    }
}
