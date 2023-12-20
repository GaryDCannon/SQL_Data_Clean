/*
Cleaning Data in SQL Queries
*/

Select *
FROM PortfolioProject..NashvilleHousing;


----------------------------------------------------------------------------------------------------

--Standardize Date Format

   --Select Data that we are updating
Select SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing;

   --Updating SaleDate column data format from datetime to date
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE;


----------------------------------------------------------------------------------------------------

--Populate Property Address data where null

   --Select Data that we are updating (finding the null PropertyAddress)
Select *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress is null;

   --Self Join using ParcelID to fill the PropertyAddress
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;

   --Updating table to fill in the PropertyAddress null values
Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;
----------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

   --Select Data that we are updating
Select PropertyAddress
FROM PortfolioProject..NashvilleHousing;

   --Checking Data for multiple commas in the PropertyAddress column (Expect 1 comma)
Select len(PropertyAddress) - len(replace(PropertyAddress, ',', '')) as CommaCount
FROM PortfolioProject..NashvilleHousing
Where len(PropertyAddress) - len(replace(PropertyAddress, ',', '')) > 1;

   --Selecting PropertyAddress as a split using the comma as a delimiter via SUBSTRING method
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing

   --Adding PropertySplitAddress and PropertySplitCity columns then filling them with PropertyAddress split data
ALTER TABLE Nashvillehousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Nashvillehousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

   --Selecting all to verify new PropertyAddress columns were added
Select *
FROM PortfolioProject..NashvilleHousing;

   --Checking Data for multiple commas in the OwnerAddress column (Expect 2 commas)
Select len(OwnerAddress) - len(replace(OwnerAddress, ',', '')) as CommaCount
FROM PortfolioProject..NashvilleHousing
Where len(OwnerAddress) - len(replace(OwnerAddress, ',', '')) <> 2;

  --Selecting OwnerAddress as a split using the comma as a delimiter via PARSENAME method
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..NashvilleHousing

   --Adding OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState columns then filling them with OwnerAddress split data
ALTER TABLE Nashvillehousing
Add OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

   --Selecting all to verify new OwnerAddress columns were added
Select *
FROM PortfolioProject..NashvilleHousing;
----------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

   --Select Data that we are updating
Select Distinct(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing

   --Creating Case Statement to verify will pull correct data
Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No' 
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing

   --Updating table with verified Case Statement
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No' 
				   ELSE SoldAsVacant
				   END
----------------------------------------------------------------------------------------------------

--Remove Duplicates via CTEs

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num

FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
