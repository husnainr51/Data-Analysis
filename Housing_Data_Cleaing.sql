-- Cleaning Data in SQL Queries



Select *
From housing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format;


Select saleDate, Cast(SaleDate as Date)
From housing;


Update housing
SET SaleDate = Cast(SaleDate as Date);

-- If it doesn't Update properly

ALTER TABLE Housing
Add SaleDateConverted Date;

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From housing
--Where PropertyAddress is null
order by ParcelID;



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, Coalesce(a.PropertyAddress,b.PropertyAddress)
From housing a
JOIN housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
Where a.PropertyAddress is null;


Update a
SET PropertyAddress = Coalesce(a.PropertyAddress,b.PropertyAddress)
From housing a
JOIN housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
Where a.PropertyAddress is null;




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From housing;
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, strpos(PropertyAddress,',') -1 ) as Address
, SUBSTRING(PropertyAddress, strpos(PropertyAddress,',') + 1 , LEN(PropertyAddress)) as Address

From housing;


ALTER TABLE housing
Add PropertySplitAddress varchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, strpos(PropertyAddress,',') -1 );


ALTER TABLE NashvilleHousing
Add PropertySplitCity varchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, strpos(PropertyAddress,',') + 1 , LEN(PropertyAddress));




Select *
From housing;





Select OwnerAddress
From housing;


Select
split_part(OwnerAddress, ',' , 1)
,split_part(OwnerAddress, ',', 2)
,split_part(OwnerAddress, ',', 3)
From housing;



ALTER TABLE Housing
Add OwnerSplitAddress varchar(255);

Update Housing
SET OwnerSplitAddress = split_part(OwnerAddress, ',' , 1);


ALTER TABLE Housing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = split_part(OwnerAddress, ',' , 1);



ALTER TABLE Housing
Add OwnerSplitState Nvarchar(255);

Update Housing
SET OwnerSplitState = split_part(OwnerAddress, ',' ,3);



Select *
From housing;




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From housing
Group by SoldAsVacant
order by 2;




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From housing;

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From housing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;


Select *
From housing;




---------------------------------------------------------------------------------------------------------

