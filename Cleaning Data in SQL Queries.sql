/*
Cleaning Data in SQL Queries
*/


select *
from PortfolioOmid..NashvilleHousing


-- Change Table Name

EXEC sp_rename 'PortfolioOmid..[Nashville Housing Data for Data Cleaning]', 'NashvilleHousing';


-- Standardize Data Format

Select saledate
from PortfolioOmid..NashvilleHousing

Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioOmid..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address data

select H1.ParcelID, H1.PropertyAddress, H2.ParcelID, H2.PropertyAddress, isnull(H1.propertyAddress, H2.propertyAddress)
from PortfolioOmid..NashvilleHousing H1
join portfolioOmid..NashvilleHousing H2
    on H1.parcelID = H2.parcelID
    and H1.uniqueID <> H2.uniqueID
where H1.propertyAddress is null


update H1
set propertyAddress = isnull(H1.propertyAddress, H2.propertyAddress)
from PortfolioOmid..NashvilleHousing H1
join portfolioOmid..NashvilleHousing H2
    on H1.parcelID = H2.parcelID
    and H1.uniqueID <> H2.uniqueID
where H1.propertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

select propertyAddress
from PortfolioOmid..NashvilleHousing

SELECT
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress) -1) as Address,
SUBSTRING(propertyAddress, CHARINDEX(',', propertyAddress) +1, len(propertyAddress)) as Address
from PortfolioOmid..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',', propertyAddress) +1, len(propertyAddress))


select *
from PortfolioOmid..NashvilleHousing


select ownerAddress
from PortfolioOmid..NashvilleHousing


select
PARSENAME(REPLACE(ownerAddress, ',','.'), 3),
PARSENAME(REPLACE(ownerAddress, ',','.'), 2),
PARSENAME(REPLACE(ownerAddress, ',','.'), 1)
from PortfolioOmid..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(ownerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(ownerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(ownerAddress, ',','.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldasVacant), count(SoldasVacant)
from PortfolioOmid..NashvilleHousing
group by SoldasVacant
order by 2

SELECT SoldasVacant,
case when SoldasVacant = 'Y' then 'Yes'
     when SoldasVacant = 'N' then 'No'
     Else SoldasVacant
     END   
from PortfolioOmid..NashvilleHousing


update NashvilleHousing
set SoldasVacant = case when SoldasVacant = 'Y' then 'Yes'
     when SoldasVacant = 'N' then 'No'
     Else SoldasVacant
     END


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

From PortfolioOmid..NashvilleHousing
--order by ParcelID
)

-- select *
-- From RowNumCTE
-- Where row_num > 1
--Order by PropertyAddress

Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

Select *
From PortfolioOmid..NashvilleHousing


-- Delete Unused Columns

Alter table PortfolioOmid..NashvilleHousing
drop COLUMN ownerAddress, TaxDistrict, PropertyAddress

Alter table PortfolioOmid..NashvilleHousing
drop COLUMN SaleDate

select *
from PortfolioOmid..NashvilleHousing