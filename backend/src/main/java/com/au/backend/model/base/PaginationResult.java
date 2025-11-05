package com.au.backend.model.base;

import lombok.Data;

/**
 * 分页结果类
 * 包含分页信息和数据
 *
 * @param <T> 数据类型
 */
@Data
public class PaginationResult<T> {
    /**
     * 当前页码
     */
    private Integer page;
    
    /**
     * 每页大小
     */
    private Integer pageSize;
    
    /**
     * 总记录数
     */
    private Integer total;
    
    /**
     * 总页数
     */
    private Integer totalPages;
    
    /**
     * 数据列表
     */
    private T data;
    
    public PaginationResult(Integer page, Integer pageSize, Integer total, Integer totalPages) {
        this.page = page;
        this.pageSize = pageSize;
        this.total = total;
        this.totalPages = totalPages;
    }
    
    public PaginationResult(Integer page, Integer pageSize, Integer total, Integer totalPages, T data) {
        this.page = page;
        this.pageSize = pageSize;
        this.total = total;
        this.totalPages = totalPages;
        this.data = data;
    }
}
