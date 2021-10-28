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
WHERE PropertyAddress IS NULL ---rows where the propertyAddress isnull


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dataCleaning_portfolio..NashVillHousing AS a
JOIN dataCleaning_portfolio..NashVillHousing AS b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>B.[UniqueID ]
WHERE a.PropertyAddress IS null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dataCleaning_portfolio..NashVillHousing AS a
JOIN dataCleaning_portfolio..NashVillHousing AS b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>B.[UniqueID ]
WHERE a.PropertyAddress IS null


--------breaking address
SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS AddressStreet,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS AddressCity
FROM dataCleaning_portfolio..NashVillHousing


ALTER TABLE dataCleaning_portfolio..NashVillHousing
ADD PropertyAddressStreet NVARCHAR(40)

UPDATE dataCleaning_portfolio..NashVillHousing
SET PropertyAddressStreet=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE dataCleaning_portfolio..NashVillHousing
ADD PropertyAddressCity NVARCHAR(30)

UPDATE  dataCleaning_portfolio..NashVillHousing
SET PropertyAddressCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


--delete the previous one(propretyAddress)

ALTER TABLE dataCleaning_portfolio..NashVillHousing
DROP COLUMN PropertyAddress

-------Owner's Addres
Select *
FROM  dataCleaning_portfolio..NashVillHousing
where OwnerAddress IS NULL;

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
       PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM  dataCleaning_portfolio..NashVillHousing

ALTER TABLE dataCleaning_portfolio..NashVillHousing
ADD OwnerAddressStreet nvarchar(30),OwnerAddressCity nvarchar(30),OwnerAddressState nvarchar(30)

UPDATE  dataCleaning_portfolio..NashVillHousing
SET OwnerAddressStreet=PARSENAME(REPLACE(OwnerAddress,',','.'),3),
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
SELECT SoldAsVacant,CASE WHEN SoldAsVacant='Yess' THEN 'Yes'
                         WHEN SoldAsVacant='NOo' THEN 'No' 
						 ELSE SoldAsVacant
						 END
FROM dataCleaning_portfolio..NashVillHousing

UPDATE  dataCleaning_portfolio..NashVillHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant='Yess' THEN 'Yes'
                         WHEN SoldAsVacant='NOo' THEN 'No' 
						 ELSE SoldAsVacant
						 END

----------Remove Duplicates-------------------------------------
-----lets do it with CTE's
WITH ROWNUM AS(
SELECT *, 
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,PropertyAddressStreet,PropertyAddressCity,SalePrice,SaleDate,LegalReference
  ORDER BY UniqueID) row_num
FROM dataCleaning_portfolio..NashVillHousing)

Delete
FROM ROWNUM
WHERE row_num>1


--Delete UnWanted Columns----I found only the taxDistrict to be not needed.
ALTER TABLE  dataCleaning_portfolio..NashVillHousing
DROP column TaxDistrict
