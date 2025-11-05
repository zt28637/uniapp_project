package com.au.backend.mapper;

import com.au.backend.model.vo.UserFrequencyVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface DashboardMapper {
    /**
     * 获取最近7天的用户使用频率（按日期统计）
     */
    @Select("SELECT DATE(create_time) AS dateStr, " +
            "COUNT(*) AS frequency " +
            "FROM user_operation_log " +
            "WHERE create_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) " +
            "GROUP BY DATE(create_time) " +
            "ORDER BY DATE(create_time) ASC")
    List<UserFrequencyVO> getUserFrequency();
}
