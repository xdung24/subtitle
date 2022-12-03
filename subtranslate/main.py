from googletrans import Translator
from httpx import Timeout
import argparse
import time
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

tokenizer_en2vi = AutoTokenizer.from_pretrained("vinai/vinai-translate-en2vi", src_lang="en_XX")
model_en2vi = AutoModelForSeq2SeqLM.from_pretrained("vinai/vinai-translate-en2vi")

def translate_en2vi(en_text: str) -> str:
    input_ids = tokenizer_en2vi(en_text, return_tensors="pt").input_ids
    output_ids = model_en2vi.generate(
        input_ids,
        do_sample=True,
        top_k=100,
        top_p=0.8,
        decoder_start_token_id=tokenizer_en2vi.lang_code_to_id["vi_VN"],
        num_return_sequences=1,
    )
    vi_text = tokenizer_en2vi.batch_decode(output_ids, skip_special_tokens=True)
    vi_text = " ".join(vi_text)
    return vi_text


# maximum number of characters on 1 line:
mcl = 60

parser = argparse.ArgumentParser()
parser.add_argument('--src-lang', type=str, required=True)
parser.add_argument('--des-lang', type=str, required=True)
parser.add_argument('--input-srt', type=str, required=True)
parser.add_argument('--output-srt', type=str, required=True)
args = parser.parse_args()

print('--------------------------------')
print('Source language:', args.src_lang)
print('Target language:', args.des_lang)
print('Input srt file:', args.input_srt)
print('Output srt file:', args.output_srt)

user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"

translator = Translator(user_agent=user_agent,timeout=Timeout(15))

orig = args.src_lang
tran = args.des_lang
sinfile = open(args.input_srt, 'r')
sout = open(args.output_srt, 'w')

sin = (sinfile.read()).splitlines()
lindex = []

# make list of line indexes that contain the timing of a new subtitle entry
for l in range(len(sin)):
    if sin[l][:3] == '00:' or sin[l][:3] == '01:' : lindex.append(l)
lindex.append(-1)

# compose out document with translation
total=len(lindex) - 1
for i in range(total):
    s = lindex[i]  # current sub index
    n = lindex[i + 1]  # next sub index
    if n == -1:
        n=len(sin)
    sub = ''
    for l in range((s + 1), (n - 1)):
        sub += sin[l] + ' '
    # translate + time delay
    # translated_sub = translator.translate(sub, src=orig, dest=tran).text
    # time.sleep(1)
    translated_sub = translate_en2vi(sub)
    print("[", i+1, "/", total, "] ", sub, " => ", translated_sub)

    sout.write(sin[s - 1] + '\n')
    sout.write(sin[s] + '\n')

    # place line breaks
    istart, iend = 0, 0
    for b in range(len(translated_sub) // mcl + 1):
        try:
            iend = translated_sub.index(' ', (b + 1) * mcl)
            sout.write(translated_sub[istart:iend] + '\n')
            istart = iend + 1
        except:
            break
    sout.write(translated_sub[istart:] + '\n\n')

sinfile.close()
sout.close()
