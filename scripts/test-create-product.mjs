import { createClient } from '@supabase/supabase-js';

async function main(){
  const SUPABASE_URL = process.env.SUPABASE_URL;
  const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if(!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY){
    console.error('Missing env vars SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
    process.exit(1);
  }
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  try{
    const payload = { title: 'Script Test Product', description: 'Inserted by local test', price: 1.23, images: [], stock: 10 };
    const { data, error } = await supabase.from('shop_items').insert([payload]).select().single();
    if(error){
      console.error('insert error', error);
      process.exit(1);
    }
    console.log('inserted', data);
  }catch(err){
    console.error('exception', err);
    process.exit(1);
  }
}

main();
