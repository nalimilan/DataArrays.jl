#' @description
#'
#' An AbstractDataArray is an Array whose entries can take on
#' values of type `T` or the value `NA`.
abstract AbstractDataArray{T, N} <: AbstractArray{T, N}

#' @description
#'
#' An AbstractDataVector is an AbstractDataArray of order 1.
typealias AbstractDataVector{T} AbstractDataArray{T, 1}

#' @description
#'
#' An AbstractDataMatrix is an AbstractDataArray of order 2.
typealias AbstractDataMatrix{T} AbstractDataArray{T, 2}

#' @description
#' Determine the type of the elements of an AbstractDataArray.
#' 
#' @param ada::AbstractDataArray{T} The AbstractDataArray whose
#'        element type is desired.
#'
#' @returns T::DataType The type of the non-NA elements of `ada`.
#'
#' @examples
#'
#' dv = @data [false, false, true, false]
#' T = eltype(dv)
Base.eltype{T, N}(d::AbstractDataArray{T, N}) = T

# Generic iteration over AbstractDataArray's

# TODO: Document
Base.start(x::AbstractDataArray) = 1

# TODO: Document
Base.next(x::AbstractDataArray, state::Integer) = (x[state], state + 1)

# TODO: Document
Base.done(x::AbstractDataArray, state::Integer) = state > length(x)

#' @description
#'
#' Determine if any of the entries of an AbstractArray are `NA`.
#'
#' @param a::AbstractArray{T, N} The AbstractArray whose elements will
#'        be assessed.
#'
#' @returns out::Bool Are any of the elements of `a` an `NA` value?
#'
#' @examples
#'
#' a = [1, 2, 3]
#' anyna(a)
anyna(a::AbstractArray) = false # -> Bool

#' @description
#'
#' Determine if any of the entries of an DataArray are `NA`.
#'
#' @param da::DataArray{T, N} The DataArray whose elements will
#'        be assessed.
#'
#' @returns out::Bool Are any of the elements of `a` an `NA` value?
#'
#' @examples
#'
#' da = @data([1, 2, 3])
#' anyna(da)
anyna(d::AbstractDataArray) = any(isna, d) # -> Bool

#' @description
#'
#' Determine if all of the entries of an AbstractArray are `NA`.
#'
#' @param a::AbstractArray{T, N} The AbstractArray whose elements will
#'        be assessed.
#'
#' @returns out::Bool Are all of the elements of `a` an `NA` value?
#'
#' @examples
#'
#' a = [1, 2, 3]
#' allna(a)
allna(a::AbstractArray) = false # -> Bool

#' @description
#'
#' Determine if all of the entries of an DataArray are `NA`.
#'
#' @param da::DataArray{T, N} The DataArray whose elements will
#'        be assessed.
#'
#' @returns out::Bool Are all of the elements of `a` an `NA` value?
#'
#' @examples
#'
#' da = @data([1, 2, 3])
#' allna(da)
allna(d::AbstractDataArray) = all(isna, d) # -> Bool

#' @description
#'
#' Determine if the values of an AbstractArray are `NA`.
#'
#' @param a::AbstractArray{T, N} The AbstractArray whose missingness will
#'        be assessed.
#'
#' @returns na::BitArray{N} Elementwise Boolean whether entry is missing.
#'
#' @examples
#'
#' a = [1, 2, 3]
#' isna(a)
isna(a::AbstractArray) = falses(size(a)) # -> BitArray

#' @description
#'
#' Safe and type-stable way to determine if element `i` of an
#' AbstractArray is `NA`.
#'
#' @param a::AbstractArray The AbstractArray whose missingness will
#'        be assessed.
#' @param i::Integer The index of the element to be checked for `NA`.
#'
#' @returns na::Bool Is the element `NA` or not?
#'
#' @examples
#'
#' a = [1, 2, 3]
#' isna(a, 1)
isna(a::AbstractArray, i::Real) = false # -> Bool

# TODO: Remove this method? It seems like a trap to me.
#' @description
#'
#' Insert a set of values, `vals`, into the positions described
#' by `inds`. The inserted values, `vals`, are echoed back as the return
#' value.
#'
#' NB: The indices in `inds` must be exhaustive.
#'
#' @param da::DataArray{T, N} A DataArray whose entries will be modified.
#' @param vals::AbstractVector A set of values to be inserted into the
#'        specified entries of `da`.
#' @param inds::AbstractVector A vector of indices of `da` to
#'        be modified.
#'
#' @returns da::DataArray{T, N} The modified DataArray.
#'
#' @examples
#'
#' da = @data([1, 2, 3])
#' da[[false, true, true]] = [5.0, 5.0]
function Base.setindex!(da::AbstractDataArray,
                        vals::AbstractVector,
                        inds::AbstractVector{Bool})
	if size(inds) != size(da)
		throw(ArgumentError("Boolean indices must be exhaustive"))
	end
    return setindex!(da, vals, find(inds))
end

#' @description
#'
#' Insert a set of values, `vals`, into the positions described
#' by `inds`. The inserted values, `vals`, are echoed back as the return
#' value.
#'
#' @param da::DataArray{T, N} A DataArray whose entries will be modified.
#' @param vals::AbstractVector A set of values to be inserted into the
#'        specified entries of `da`.
#' @param inds::AbstractVector A vector of indices of `da` to
#'        be modified.
#'
#' @returns da::DataArray{T, N} The modified DataArray.
#'
#' @examples
#'
#' da = @data([1, 2, 3])
#' da[[1, 3]] = [5.0, 5.]
function Base.setindex!(da::AbstractDataArray,
                        vals::AbstractVector,
                        inds::AbstractVector)
	if length(vals) != length(inds)
		throw(ArgumentError("Values and indices must have the same length"))
	end
    for (val, ind) in zip(vals, inds)
        da[ind] = val
    end
    return da
end

#' @description
#'
#' Insert a value, `val`, of type `Any` into the positions described
#' by `inds`. The inserted value, `val`, is echoed back as the return
#' value.
#'
#' NB: The indices in `inds` must be exhaustive.
#'
#' @param da::DataArray{T, N} A DataArray whose entries will be modified.
#' @param val::Any A value to be inserted into the specified entries of `da`.
#' @param inds::AbstractVector{Bool} A Boolean vector of indices of `da` to
#'        be modified.
#'
#' @returns da::DataArray{T, N} The modified DataArray.
#'
#' @examples
#'
#' da = @data([1, 2, 3])
#' da[[false, true]] = 5.0
function Base.setindex!{T}(da::AbstractDataArray{T},
                           val::Any,
                           inds::AbstractVector{Bool})
    return setindex!(da, convert(T, val), find(inds))
end

#' @description
#'
#' Insert a value, `val`, of type `Any` into the positions described
#' by `inds`. The inserted value, `val`, is echoed back as the return
#' value. Note that `val` be coerced to the element type of `da`, which
#' may fail.
#'
#'
#' @param da::DataArray{T, N} A DataArray whose entries will be modified.
#' @param val::Any A value to be inserted into the specified entries of `da`.
#' @param inds::AbstractVector A vector of indices of `da` to be modified.
#'
#' @returns da::DataArray{T, N} The modified DataArray.
#'
#' @examples
#'
#' da = @data([1, 2, 3])
#' da[1:3] = 5.0
function Base.setindex!{T}(da::AbstractDataArray{T},
                           val::Any,
                           inds::AbstractVector)
    val = convert(T, val)
    for ind in inds
        da[ind] = val
    end
    return da
end

# TODO: Include BitArray indexing here.
#' @description
#'
#' Insert a value, `val`, of type `Any` into the positions described
#' by `inds`. The inserted value, `val`, is echoed back as the return
#' value.
#'
#' NB: The vector of indices, `inds`, must exhausitively state for every
#' element of `da` whether it is being modified or not.
#'
#' @param da::DataArray{T, N} A DataArray whose entries will be modified.
#' @param val::Any A value to be inserted into the specified entries of `da`.
#' @param inds::AbstractVector A vector of indices of `da` to be modified.
#'
#' @returns da::DataArray{T, N} The modified DataArray.
#'
#' @examples
#'
#' da = @data([1, 2, 3])
#' da[[true, false, false]] = 5.0
function Base.setindex!(da::AbstractDataArray,
                        val::Any,
                        inds::AbstractVector{Bool})
    # TODO: Make inds a BooleanIndex
    if size(inds) != size(da)
        throw(ArgumentError("Boolean indices must be exhausitive"))
    end
    return setindex!(da, val, find(inds))
end

#' @description
#'
#' Insert a value, `val`, of type `Any` into the positions described
#' by `inds`. The inserted value, `val`, is echoed back as the return
#' value.
#'
#' @param da::DataArray{T, N} A DataArray whose entries will be modified.
#' @param val::Any A value to be inserted into the specified entries of `da`.
#' @param inds::AbstractVector A vector of indices of `da` to be modified.
#'
#' @returns da::DataArray{T, N} The modified DataArray.
#'
#' @examples
#'
#' da = @data([1, 2, 3])
#' da[[1, 2]] = 5.0
function Base.setindex!{T}(da::AbstractDataArray{T},
                           val::Any,
                           inds::AbstractVector)
    val = convert(T, val)
    for ind in inds
        da[ind] = val
    end
    return da
end
