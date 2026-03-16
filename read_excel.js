const XLSX = require('xlsx');

const workbook = XLSX.readFile('7-1-2026.xlsx');
const sheetName = workbook.SheetNames[0];
const sheet = workbook.Sheets[sheetName];
const data = XLSX.utils.sheet_to_json(sheet);

const products = [];
const categoryMap = {
  'ટામેટા': 'Tomatoes',
  'બટેકા': 'Potatoes',
  'કાંદા': 'Onions',
  'કોબી': 'Cabbage',
  'સિમલા': 'Capsicum',
  'આદુ': 'Ginger',
  'મર્સી': 'Mirchi',
  'મકાઈ': 'Sweet Corn',
  'કાકડી': 'Cucumber',
  'લાંબા': 'Beans',
  'ભૉલાર': 'Cluster Beans',
  'લીંબુ': 'Lemon',
  'રીંગણા': 'Brinjal',
  'પરવર': 'Parwal',
  'પાપડી': 'Papdi',
  'ફણસી': 'Fanasi/Guvar',
  'તુરીયા': 'Turiya',
  'સ્ટાફ': 'Staff',
  'ફ્લાવર': 'Cauliflower',
  'કોળું': 'Pumpkin',
  'ગાજર': 'Carrot',
  'બીટ': 'Beetroot',
  'રતાળુ': 'Radish',
  'સાકરીયા': 'Sugarcane',
  'સૂરણ': 'Sugarcane',
  'આંબા': 'Mango Raw',
  'પાલક': 'Spinach',
  'ધાણા': 'Coriander',
  'લસણ': 'Garlic',
  'મેથી': 'Fenugreek',
  'ફુદીનો': 'Fudino',
  'લીમડી': 'Lemon Raw',
  'સરગવો': 'Sargavo',
  'વટાણા': 'Peas',
  'જુગનુ': 'Jugnu',
  'બ્રોકલી': 'Broccoli',
  'ચેરી': 'Cherry',
  'સેલરી': 'Celery',
  'મશરૂમ': 'Mushroom',
  'કોર્ન': 'Corn',
  'પત્તા': 'Patta',
  'પરસલિક': 'Parsley',
  'લીલવા': 'Lilva',
  'કેળા': 'Banana',
  'વાલોર': 'Valoor',
  'દૂધી': 'Doodhi',
  'ચોળી': 'Chori',
  'ગવાર': 'Gavar',
  'કેરી': 'Mango',
  'મૂળા': 'Mooli',
  'ભીંડી': 'Bhindi',
  'કારેલા': 'Karela',
  'પોપ્યાં': 'Popaya',
  'જમરૂખ': 'Jamruk',
  'સફરજન': 'Orange',
  'દાડમ': 'Pomegranate',
  'તિંદોર': 'Tindora',
  'દ્રાક્ષ': 'Grapes',
};

for (const row of data) {
  const nameGu = row['__EMPTY'];
  const price = row['__EMPTY_1'];
  
  if (!nameGu || nameGu === 'ITEMS ' || nameGu.includes('max') || nameGu.includes('સવારે')) {
    continue;
  }
  
  let category = 'Other';
  for (const [key, val] of Object.entries(categoryMap)) {
    if (nameGu.includes(key)) {
      category = val;
      break;
    }
  }
  
  products.push({
    name_gu: nameGu.trim(),
    name_en: category === 'Other' ? nameGu.trim() : category,
    max_price: price || 0,
    category: category
  });
}

console.log('Products to insert:');
console.log(JSON.stringify(products, null, 2));

console.log('\n\nCategories:');
const categories = [...new Set(products.map(p => p.category))];
console.log(JSON.stringify(categories, null, 2));
