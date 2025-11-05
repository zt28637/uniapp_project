package com.au.backend.model.vo;

import lombok.Data;

import java.util.Date;

@Data
public class UserFrequencyVO {
    private Long userId;
    private Integer frequency;
    private Date date;
    private String dateStr;
}
