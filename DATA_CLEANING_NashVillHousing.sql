--main Table---------------------------------------------------------------------
SELECT *
FROM dataCleaning_portfolio..NashVillHousing

-------CLEANING DATA IN SQL------------------------------------------------------

---Standardize Date Format-------------------------------------------------------

SELECT SaleDate,CONVERT(DATE,SaleDate)
FROM dataCleaning_portfolio..NashVillHousing

UPDATE dataCleaning_portfolio..NashVillHousing
SET SaleDate=CONVERT(DATE,SaleDate);---query isn't executes,but doesn't give correct output

ALTER TABLE dataCleaning_portfolio..NashVillHousing
ALTER COLUMN SaleDate DATE--executed Succesfully

---populate Property Address Data

SELECT *
FROM dataCleaning_portfolio..NashVillHousing
where PropertyAddress is NULL ---rows where the propertyAddress isnull


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from dataCleaning_portfolio..NashVillHousing as a
join dataCleaning_portfolio..NashVillHousing as b
on a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>B.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from dataCleaning_portfolio..NashVillHousing as a
join dataCleaning_portfolio..NashVillHousing as b
on a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>B.[UniqueID ]
WHERE a.PropertyAddress is null


--------breaking address
SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as AddressStreet,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS AddressCity
from dataCleaning_portfolio..NashVillHousing


ALTER TABLE dataCleaning_portfolio..NashVillHousing
ADD PropertyAddressStreet nvarchar(40)

update dataCleaning_portfolio..NashVillHousing
set PropertyAddressStreet=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE dataCleaning_portfolio..NashVillHousing
ADD PropertyAddressCity nvarchar(25)

update  dataCleaning_portfolio..NashVillHousing
set PropertyAddressCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


--delete the previous one(propretyAddress)

ALTER TABLE dataCleaning_portfolio..NashVillHousing
DROP COLUMN PropertyAddress

-------Owner's Addres
Select *
FROM  dataCleaning_portfolio..NashVillHousing
where OwnerAddress is null;

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
       PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from  dataCleaning_portfolio..NashVillHousing

ALTER table dataCleaning_portfolio..NashVillHousing
add OwnerAddressStreet nvarchar(30),OwnerAddressCity nvarchar(30),OwnerAddressState nvarchar(30)

update  dataCleaning_portfolio..NashVillHousing
set OwnerAddressStreet=PARSENAME(REPLACE(OwnerAddress,',','.'),3),
    OwnerAddressCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerAddressState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)

ALTER TABLE dataCleaning_portfolio..NashVillHousing
DROP COLUMN OwnerAddress
---------------change Y to Yes and N to No in SoldAsVacant

UPDATE dataCleaning_portfolio..NashVillHousing
SET SoldAsVacant= REPLACE(SoldAsVacant, 'Y', 'Yes'),
     SoldAsVacant= REPLACE(SoldAsVacant, 'N', 'NO')

UPDATE dataCleaning_portfolio..NashVillHousing
SET  SoldAsVacant= REPLACE(SoldAsVacant, 'N', 'NO')--Ithought this would work
                                                  --But,it replaced every N and Y like..no necame noo ad yes became Yess
												  --so go for the next method--use this only when the thing replacing id unique
--another way
Select SoldAsVacant,Case when SoldAsVacant='Yess' Then 'Yes'
                         when SoldAsVacant='NOo' then 'No' 
						 else SoldAsVacant
						 End
from dataCleaning_portfolio..NashVillHousing

Update  dataCleaning_portfolio..NashVillHousing
set SoldAsVacant=Case when SoldAsVacant='Yess' Then 'Yes'
                         when SoldAsVacant='NOo' then 'No' 
						 else SoldAsVacant
						 End

----------Remove Duplicates-------------------------------------
-----lets do it with CTE's
with ROWNUM as(
SELECT *, 
  ROW_NUMBER() Over (
  Partition by ParcelID,PropertyAddressStreet,PropertyAddressCity,SalePrice,SaleDate,LegalReference
  Order by UniqueID) row_num
FROM dataCleaning_portfolio..NashVillHousing)

Delete
from ROWNUM
where row_num>1


--Delete UnWanted Columns----I found only the taxDistrict to be not needed.
Alter table  dataCleaning_portfolio..NashVillHousing
DROP column TaxDistrict