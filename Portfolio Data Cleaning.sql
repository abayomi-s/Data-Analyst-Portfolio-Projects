/*
Data Cleaning Portfolio Project
*/

-- View the data
Select *
From NashVilleHousing

-- Change the SaleDate

Alter Table NashvilleHousing
Add SalesDateConverted Date

Update NashVilleHousing
Set SalesDateConverted= Convert(date, SaleDate)

Select SalesDateConverted
From NashVilleHousing

--Populate Property Address if Null
Select *
From NashVilleHousing
Where PropertyAddress is null

Select a.PropertyAddress, a.ParcelID, b.PropertyAddress, b.ParcelID, isnull(a.PropertyAddress, b.PropertyAddress)
From NashVilleHousing a
Join NashVilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashVilleHousing a
Join NashVilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- Break Address into Components
Select PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From NashVilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashVilleHousing
Set PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
From NashVilleHousing

Update NashVilleHousing
Set PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
From NashVilleHousing

Select PropertyAddress,PropertySplitAddress, PropertySplitCity
From NashVilleHousing

-- Break OWner Address
Select OwnerAddress,
PARSENAME(Replace(OwnerAddress, ',', '.'),3),
PARSENAME(Replace(OwnerAddress, ',', '.'),2),
PARSENAME(Replace(OwnerAddress, ',', '.'),1)
From NashVilleHousing

Alter Table NashvilleHousing
Add SplitOwnerAddress nvarchar(255)

Alter Table NashvilleHousing
Add SplitOwnerCity nvarchar(255)

Alter Table NashvilleHousing
Add SplitOwnerState nvarchar(255)

Update NashVilleHousing
Set SplitOwnerAddress = PARSENAME(Replace(OwnerAddress, ',', '.'),3)
From NashVilleHousing

Update NashVilleHousing
Set SplitOwnerCity= PARSENAME(Replace(OwnerAddress, ',', '.'),2)
From NashVilleHousing

Update NashVilleHousing
Set SplitOwnerState= PARSENAME(Replace(OwnerAddress, ',', '.'),1)
From NashVilleHousing

Select OwnerAddress, SplitOwnerAddress, SplitOwnerCity, SplitOwnerState
From NashVilleHousing

--Change Y and N to Yes and No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashVilleHousing
Group by SoldAsVacant
order by 2

Select Distinct(SoldAsVacant),
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From NashVilleHousing

Update NashVilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

--Remove Duplicates

With CTERowNum as
(
Select *,
	ROW_NUMBER () over (
	Partition By ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				Order by UniqueID
				) RowNum
From NashVilleHousing
)
Select *
From CTERowNum
where RowNum > 1

-- Delete Unused Columns

Alter Table NashvilleHousing
Drop Column PropertyAddress