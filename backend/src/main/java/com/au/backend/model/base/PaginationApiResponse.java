package com.au.backend.model.base;

/**
 * PaginationApiResponse类用于处理分页的API响应
 * 它继承自ApiResponse类，并添加了分页信息的支持
 *
 * @param <T> 泛型参数，表示API响应中携带的数据类型
 */
public class PaginationApiResponse<T> extends ApiResponse<T> {
    // 分页信息对象
    private final Pagination pagination;

    /**
     * 构造方法，用于创建PaginationApiResponse对象
     *
     * @param code    响应代码
     * @param msg     响应消息
     * @param data    响应数据，类型为泛型T
     * @param pagination 分页信息对象，包含分页相关数据
     */
    public PaginationApiResponse(int code, String msg, T data, Pagination pagination) {
        super(code, msg, data); // 调用父类ApiResponse的构造方法
        this.pagination = pagination; // 初始化分页信息
    }

    /**
     * 构造方法，用于创建PaginationApiResponse对象（使用PaginationResult）
     *
     * @param code    响应代码
     * @param msg     响应消息
     * @param data    响应数据，类型为泛型T
     * @param paginationResult 分页结果对象
     */
    public PaginationApiResponse(int code, String msg, T data, PaginationResult<?> paginationResult) {
        super(code, msg, data);
        this.pagination = new Pagination(
            paginationResult.getPage(),
            paginationResult.getPageSize(),
            paginationResult.getTotal()
        );
    }

    /**
     * 创建成功的分页响应（使用PaginationResult）
     *
     * @param msg     响应消息
     * @param data    响应数据
     * @param paginationResult 分页结果对象
     * @return PaginationApiResponse
     */
    public static <T> PaginationApiResponse<T> success(String msg, T data, PaginationResult<?> paginationResult) {
        return new PaginationApiResponse<>(200, msg, data, paginationResult);
    }

    /**
     * 创建错误的分页响应
     *
     * @param msg     错误消息
     * @return PaginationApiResponse
     */
    public static <T> PaginationApiResponse<T> error(String msg) {
        return new PaginationApiResponse<>(400, msg, null, new Pagination(1, 10, 0));
    }

    /**
     * 获取分页信息的方法
     *
     * @return 返回Pagination对象，包含分页相关数据
     */
    public Pagination getPagination() {
        return pagination;
    }
}
