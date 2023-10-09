
Select *
From [Portfolio Project].dbo.NashvilleHousingData$

--Standardize date format

Update NashvilleHousingData$
set SaleDate = Convert(Date,SaleDate)

Alter table NashvilleHousingData$
Add SaleDateConverted Date;

Update NashvilleHousingData$
set SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted, SaleDate
From [Portfolio Project].dbo.NashvilleHousingData$

--Populate Property address


Select *
From [Portfolio Project].dbo.NashvilleHousingData$
where PropertyAddress is null

Select a.[UniqueID ],a.ParcelID, a.PropertyAddress,b.PropertyAddress, b.ParcelID
, isnull(a.propertyaddress,b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousingData$ a
join [Portfolio Project].dbo.NashvilleHousingData$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = isnull(a.propertyaddress,b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousingData$ a
join [Portfolio Project].dbo.NashvilleHousingData$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking down Adress into separate columns like address,city

Select PropertyAddress
From [Portfolio Project].dbo.NashvilleHousingData$
--where PropertyAddress is null

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress)) as city
From NashvilleHousingData$

Alter table NashvilleHousingData$
Add SplitPropertyAddress nvarchar(255);

Update NashvilleHousingData$
set SplitPropertyAddress = substring(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1)
 
Alter table NashvilleHousingData$
Add SplitPropertyAddressCity nvarchar(255);

Update NashvilleHousingData$
set SplitPropertyAddressCity = substring(PropertyAddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress))


---Owners Address
Select owneraddress
From NashvilleHousingData$

Select
PARSENAME(Replace(owneraddress,',','.'),3),
PARSENAME(Replace(owneraddress,',','.'),2),
PARSENAME(Replace(owneraddress,',','.'),1)
From NashvilleHousingData$

Alter table NashvilleHousingData$
Add SplitOwnerAddress nvarchar(255);

Update NashvilleHousingData$
set SplitOwnerAddress = PARSENAME(Replace(owneraddress,',','.'),2)

Alter table NashvilleHousingData$
Add SplitOwnerCity nvarchar(255);

Update NashvilleHousingData$
set SplitOwnerCity = PARSENAME(Replace(owneraddress,',','.'),2)

Alter table NashvilleHousingData$
Add SplitOwnerState nvarchar(255);

Update NashvilleHousingData$
set SplitOwnerState = PARSENAME(Replace(owneraddress,',','.'),1)

Select *
From NashvilleHousingData$

--Change Y/N to yes /NO 

Select Distinct(SoldAsVacant),count(soldAsVacant)
From NashvilleHousingData$
group by SoldAsVacant
order by SoldAsVacant


Select SoldAsVacant
, Case   when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVAcant = 'N' then 'No'
		 Else SoldAsVacant
		 END
From NashvilleHousingData$

Update NashvilleHousingData$
Set SoldAsVacant = Case   when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVAcant = 'N' then 'No'
		 Else SoldAsVacant
		 END

--Delete duplicates

With rownumCTE as(
Select *,
		Row_Number() over (
		Partition by ParcelId,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		order by 
		uniqueID)row_num
From NashvilleHousingData$
)
--Delete
Select *
From rownumCTE
where row_num>1
order by PropertyAddress


--Delete unwanted Columns

Select * 
From NashvilleHousingData$

Alter Table NashvilleHousingData$
Drop Column PropertyAddress, OwnerAddress, TaxDistrict

Alter Table NashvilleHousingData$
Drop Column SaleDate