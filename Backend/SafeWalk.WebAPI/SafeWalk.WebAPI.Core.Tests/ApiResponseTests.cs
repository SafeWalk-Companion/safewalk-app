using System.Net;
using SafeWalk.WebAPI.Core.Responses;
using Xunit;

namespace SafeWalk.WebAPI.Core.Tests;

public class ApiResponseTests
{
    [Fact]
    public void Ok_NoPayload_SetsSuccess200()
    {
        var res = ApiResponse.Ok("ok");
        Assert.True(res.Success);
        Assert.Equal((int)HttpStatusCode.OK, res.StatusCode);
        Assert.Equal("ok", res.Message);
        Assert.Null(res.Errors);
    }

    [Fact]
    public void Created_NoPayload_SetsSuccess201()
    {
        var res = ApiResponse.Created("created");
        Assert.True(res.Success);
        Assert.Equal((int)HttpStatusCode.Created, res.StatusCode);
        Assert.Equal("created", res.Message);
    }

    [Fact]
    public void Fail_NoErrors_SetsFailureAndStatus()
    {
        var res = ApiResponse.Fail(HttpStatusCode.BadRequest, "bad");
        Assert.False(res.Success);
        Assert.Equal((int)HttpStatusCode.BadRequest, res.StatusCode);
        Assert.Equal("bad", res.Message);
        Assert.Null(res.Errors);
    }

    [Fact]
    public void Fail_WithErrors_PropagatesErrors()
    {
        var errs = new[] { new ApiError("code","msg","field") };
        var res = ApiResponse.Fail(HttpStatusCode.UnprocessableEntity, "invalid", errs);
        Assert.False(res.Success);
        Assert.Equal((int)HttpStatusCode.UnprocessableEntity, res.StatusCode);
        Assert.NotNull(res.Errors);
        Assert.Single(res.Errors!);
        Assert.Equal("code", res.Errors![0].Code);
    }

    [Fact]
    public void Ok_Generic_SetsData()
    {
        var res = ApiResponse<string>.Ok("data", "ok");
        Assert.True(res.Success);
        Assert.Equal((int)HttpStatusCode.OK, res.StatusCode);
        Assert.Equal("ok", res.Message);
        Assert.Equal("data", res.Data);
    }

    [Fact]
    public void Created_Generic_SetsData201()
    {
        var res = ApiResponse<int>.Created(7, "created");
        Assert.True(res.Success);
        Assert.Equal((int)HttpStatusCode.Created, res.StatusCode);
        Assert.Equal(7, res.Data);
    }

    [Fact]
    public void Fail_Generic_SetsFailureAndNoData()
    {
        var res = ApiResponse<object>.Fail(HttpStatusCode.Forbidden, "no");
        Assert.False(res.Success);
        Assert.Equal((int)HttpStatusCode.Forbidden, res.StatusCode);
        Assert.Null(res.Data);
    }
}

