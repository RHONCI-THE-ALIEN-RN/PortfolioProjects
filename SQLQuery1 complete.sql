
/*

Cleaning data in SQL Queries

*/


SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing
------------------------------------------------------------------------

--  Change Sale Date format


SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM ProjectPortfolio..NashvilleHousing


UPDATE ProjectPortfolio..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Alter Table projectportfolio..NashvilleHousing
ADD saleDateConverted Date;

Update projectportfolio..NashvilleHousing
SET saleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------------

--Populate addrees data


SELECT PropertyAddress
FROM ProjectPortfolio..NashvilleHousing

SELECT PropertyAddress
FROM ProjectPortfolio..NashvilleHousing
WHERE PropertyAddress is null


SELECT *
FROM ProjectPortfolio..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

---Using a self join and ISNULL 
SELECT NH1.ParcelID, NH1.PropertyAddress, NH2.ParcelID, NH2.PropertyAddress,ISNULL(NH1.PropertyAddress,NH2.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing NH1
JOIN ProjectPortfolio..NashvilleHousing NH2
	ON NH1.ParcelID = NH2.ParcelID
	AND NH1.[UniqueID ] <> NH2.[UniqueID ]
WHERE NH1.PropertyAddress is null

---- Removed where address had null value
UPDATE NH1
SET PropertyAddress = ISNULL(NH1.PropertyAddress,NH2.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing NH1
JOIN ProjectPortfolio..NashvilleHousing NH2
	ON NH1.ParcelID = NH2.ParcelID
	AND NH1.[UniqueID ] <> NH2.[UniqueID ]
WHERE NH1.PropertyAddress is null


------------------------------------

---  Full Adrress to individual columns

SELECT PropertyAddress
FROM ProjectPortfolio.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress)) as Address
FROM ProjectPortfolio.dbo.NashvilleHousing

--- Create columns and add address info

Alter Table projectportfolio..NashvilleHousing
ADD PropertyAddressStreet NVARCHAR(255)

Update projectportfolio..NashvilleHousing
SET PropertyAddressStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table projectportfolio..NashvilleHousing
ADD PropertyAddressCity NVARCHAR(255)

Update projectportfolio..NashvilleHousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress))


SELECT*
FROM projectportfolio..NashvilleHousing

--- Updating table and Placing Owner address into columns using parsename
-----------------------------------------------------------------------

SELECT OwnerAddress
FROM projectportfolio..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM projectportfolio..NashvilleHousing


Alter Table projectportfolio..NashvilleHousing
ADD OwnerAddressStreet NVARCHAR(255)

Update projectportfolio..NashvilleHousing
SET OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

Alter Table projectportfolio..NashvilleHousing
ADD OwnerAddressCity NVARCHAR(255)

Update projectportfolio..NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


Alter Table projectportfolio..NashvilleHousing
ADD OwnerAddressState NVARCHAR(255)

Update projectportfolio..NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


SELECT*
FROM projectportfolio..NashvilleHousing

----------------------------------------------------------------------------

--- change y and N to Yes and No in "sold as vacant"

SELECT DISTINCT(SoldAsVacant),  COUNT(SoldAsVacant)
FROM ProjectPortfolio.dbo.NashvilleHousing
Group By SoldAsVacant
order by 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM ProjectPortfolio.dbo.NashvilleHousing

UPDATE ProjectPortfolio.dbo.NashvilleHousing
SET SoldAsVacant = 	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

-------------------------------------------------------

---- Finding an Removing Duplicates and use CTE

SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM ProjectPortfolio..NashvilleHousing
ORDER BY ParcelID

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM ProjectPortfolio..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


---Removing  duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM ProjectPortfolio..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

--- 104 Rows Deleted

------------------------------------------------------------

-- Deleting unused columns


SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

--------------------------------------------------------------------------------------------------------






