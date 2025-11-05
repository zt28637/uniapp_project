package com.au.backend.service;

import com.au.backend.mapper.DashboardMapper;
import com.au.backend.model.base.ApiResponse;
import com.au.backend.model.dto.ChartDataDTO;
import com.au.backend.model.vo.UserFrequencyVO;
import com.au.backend.util.ApiResponseUtil;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@AllArgsConstructor
public class DashboardService {

    private final DashboardMapper dashboardMapper;

    public ApiResponse<ChartDataDTO> getUserFrequency() {
        try {
            List<UserFrequencyVO> list = dashboardMapper.getUserFrequency();

            // 创建日期到频率的映射
            Map<String, Integer> dateFrequencyMap = new HashMap<>();
            SimpleDateFormat dbFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat displayFormat = new SimpleDateFormat("MM-dd");
            
            // 存储所有日期用于排序
            List<Date> dateList = new ArrayList<>();
            
            for (UserFrequencyVO vo : list) {
                if (vo.getDateStr() != null) {
                    try {
                        // 解析数据库返回的日期字符串
                        String dateStr = vo.getDateStr();
                        if (dateStr.length() > 10) {
                            dateStr = dateStr.substring(0, 10);
                        }
                        Date date = dbFormat.parse(dateStr);
                        dateList.add(date);
                        dateFrequencyMap.put(dateStr, vo.getFrequency());
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                }
            }
            
            // 如果没有数据，返回空列表
            if (dateList.isEmpty()) {
                ChartDataDTO data = new ChartDataDTO(new ArrayList<>(), new ArrayList<>());
                return ApiResponseUtil.success("获取成功，暂无数据", data);
            }
            
            // 只显示有数据的日期，不填充空日期
            // 按日期排序（从早到晚）
            dateList.sort(Date::compareTo);
            
            // 如果数据超过7天，只取最近的7个有数据的日期
            List<Date> filteredDateList = dateList;
            if (dateList.size() > 7) {
                // 取最后7个（最新的）
                filteredDateList = dateList.subList(dateList.size() - 7, dateList.size());
            }
            
            // 生成显示列表（只包含有数据的日期）
            List<String> displayDateList = new ArrayList<>();
            List<Integer> frequencyList = new ArrayList<>();
            
            for (Date date : filteredDateList) {
                String dateKey = dbFormat.format(date);
                String displayDate = displayFormat.format(date);
                
                displayDateList.add(displayDate);
                frequencyList.add(dateFrequencyMap.get(dateKey));
            }
            
            // 调试日志
            System.out.println("=== 返回给前端的数据 ===");
            System.out.println("日期列表: " + displayDateList);
            System.out.println("频率列表: " + frequencyList);
            System.out.println("数据点数量: " + displayDateList.size());
            System.out.println("========================");

            ChartDataDTO data = new ChartDataDTO(displayDateList, frequencyList);
            return ApiResponseUtil.success("获取成功", data);

        } catch (Exception e) {
            e.printStackTrace();
            return ApiResponseUtil.error("获取用户使用频率失败");
        }
    }
}
