            
			-- Nashville Housing Data Cleaning --

-- Step-1 Gets started Cleaning the Data in SQL Queries

Select *
From [Nashville Housing].dbo.[NashvilleHousingData ]

-- Step-2 Standardize the Data Format --

Select SaleDateConverted, CONVERT(Date,SaleDate)
From [Nashville Housing].dbo.[NashvilleHousingData ]

Update [NashvilleHousingData ]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [NashvilleHousingData ]
Add SaleDateConverted Date;

Update [NashvilleHousingData ]
SET SaleDateConverted = CONVERT(Date,SaleDate)

---------------------------------------------------------------------

-- Step-3 Now Populate the property Address Data

Select * --PropertyAddress
From [Nashville Housing].dbo.[NashvilleHousingData ]
--Where PropertyAddress is null
Order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing].dbo.[NashvilleHousingData ] a
JOIN  [Nashville Housing].dbo.[NashvilleHousingData ] b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing].dbo.[NashvilleHousingData ] a
JOIN  [Nashville Housing].dbo.[NashvilleHousingData ] b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

---------------------------------------------------------------------

                             -- Step-4 --

-- Now Breaking Out Aeddress into Indivisual Columns (Address, City, State)

Select PropertyAddress
From [Nashville Housing].dbo.[NashvilleHousingData ]
--Where PropertyAddress is null
--Order by ParcelID


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From [Nashville Housing].dbo.[NashvilleHousingData ]

ALTER TABLE [NashvilleHousingData ]
Add PropertySplitAddress Nvarchar(255);

Update [NashvilleHousingData ]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


ALTER TABLE [NashvilleHousingData ]
Add PropertySplitCity Nvarchar(255);

Update [NashvilleHousingData ]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 



SELECT *
From [Nashville Housing].dbo.[NashvilleHousingData ]



SELECT OwnerAddress
From [Nashville Housing].dbo.[NashvilleHousingData ]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From [Nashville Housing].dbo.[NashvilleHousingData ]


ALTER TABLE [NashvilleHousingData ]
Add OwnerSplitAddress Nvarchar(255);

Update [NashvilleHousingData ]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


ALTER TABLE [NashvilleHousingData ]
Add OwnerSplitCity Nvarchar(255);

Update [NashvilleHousingData ]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE [NashvilleHousingData ]
Add OwnerSplitState Nvarchar(255);

Update [NashvilleHousingData ]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


SELECT *
From [Nashville Housing].dbo.[NashvilleHousingData ]

---------------------------------------------------------------------

                           -- Step-5 --

-- Change Y and N to Yes and No in "Solid as Vacant" field

select Distinct(SoldAsVacant),Count(SoldAsVacant)
From [Nashville Housing].dbo.[NashvilleHousingData ]
group by SoldAsVacant
Order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
   When SoldAsVacant = 'N' Then 'No'
   ELSE SoldAsVacant
   END
From [Nashville Housing].dbo.[NashvilleHousingData ]


Update [NashvilleHousingData ]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
   When SoldAsVacant = 'N' Then 'No'
   ELSE SoldAsVacant
   END

---------------------------------------------------------------------

       -- Step-6 --
-- Now Removing Duplicates --

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
				   )row_num

 From [Nashville Housing].dbo.[NashvilleHousingData ]
 --Order By ParcelID
 )
 --DELETE
 SELECT *
 FROM RowNumCTE
 Where row_num > 1
 --Order By PropertyAddress


 ---------------------------------------------------------------------
                 -- Step-7 --
-- Now we have to DELETE some UNUSED COLUMNS --

Select *
From [Nashville Housing].dbo.[NashvilleHousingData ]


ALTER TABLE [Nashville Housing].dbo.[NashvilleHousingData ]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Nashville Housing].dbo.[NashvilleHousingData ]
DROP COLUMN SaleDate