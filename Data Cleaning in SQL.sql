--Cleaning Data in SQL

--Check the table imported
Select *
from [Portfolio Project2].dbo.NashvilleHousing


--Standardize Sale Date Format
Select SaleDate, SaleDateConverted
from NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)


Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address data

Select *
from NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Update a
Set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out Address into individual columns(Address, City, State)
Select PropertyAddress
from NashvilleHousing

--Using Substrings
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as City
From NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))

Select PropertySplitAddress,PropertySplitCity, PropertyAddress
From NashvilleHousing


--Using Parsename
Select OwnerAddress
From NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress, ',', '.') ,3) as Address
,PARSENAME(Replace(OwnerAddress, ',', '.') ,2) as City
,PARSENAME(Replace(OwnerAddress, ',', '.') ,1) as State
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)

Select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From NashvilleHousing

--Change Y and N to Yes and No in Sold as Vacant field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select Distinct(SoldAsVacant)
, Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From NashvilleHousing


--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
					UniqueID
					) row_num
From NashvilleHousing
)

Select *
from RowNumCTE
Where row_num >1
Order by PropertyAddress


--Delete Unused Columns

Select * 
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, PropertyAddress

Alter Table NashvilleHousing
Drop Column SaleDate

