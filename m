From: liuduo <liuduo@sinosoft.com.cn>
Date: Fri, 16 Jan 2004 07:12:17 +0000
Subject: Re: a question about memory access on IA64
Message-Id: <40078ED1.9080508@sinosoft.com.cn>
List-Id: <linux-ia64.vger.kernel.org>
References: <40075464.6010202@sinosoft.com.cn>
In-Reply-To: <40075464.6010202@sinosoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi:
Thanks for your help, i have solved the problem
Have a good time !

yours: calis

Martin Pool wrote:

>Please reply to the list, not to me.
>
>On 16 Jan 2004, liuduo <liuduo@sinosoft.com.cn> wrote:
>
>>Martin Pool wrote:
>>
>>>On 16 Jan 2004, liuduo <liuduo@sinosoft.com.cn> wrote:
>>>
>>>>David:
>>>>Sorry, i only describe the process about the error occurs .
>>>>
>>>> typedef struct b{
>>>>   char*  pDescriptName;
>>>>   char*           pVendorName;
>>>>   unsigned int	RevisionID;
>>>>  }B;
>>>>
>>>> typedef struct pci{
>>>>  int c;
>>>>  struct b bb[512];
>>>>  }PCI;
>>>>
>>>>int main()
>>>>{
>>>>
>>>>
>>>>  struct pci a;
>>>>
>>>>  //function for operation a
>>>>  func(&a);
>>>>  return 0;
>>>>}
>>>>
>>>>the func is in an lib, it's an lib export function, and the func is as 
>>>>follows;
>>>>
>>>Do you mean that it works if you use the first struct definition, and
>>>if you pu the func into the same file? 
>>>
>>yes
>>
>>>Does it have to be in a
>>>library to fail?
>>>
>>yes
>>
>>>
>>>Could it be that you are using different structure packing for
>>>building the library, either through compiler options or #pragmas in
>>>some other header file?
>>>
>>we use the #pragma pack (1)  in the file that the func is in it.
>>
>
>Don't do that then.  If you access a struct with different packing
>conventions, your program will lose its fingers.
>
>>>>func(struct pci* a)
>>>>{
>>>>   char tmp[256];
>>>>  for(num=0;num<512;num++)
>>>>  {
>>>>   a->bb[num].pDescriptName = (char*)malloc(100);
>>>>   strcpy(a->bb[num].pDescriptName , "dddd");
>>>>   a->bb[num].pVendorName = (char*)malloc(100);
>>>>   strcpy(a->bb[num].pVendorName , "fffff");
>>>>   a->bb[num].RevisionID = 22;
>>>>  }
>>>>  a->c = 512;
>>>>}
>>>>when call the func , the segmentation fault occurs,
>>>>and then we modified the struct A as follows
>>>>  typedef struct pci{
>>>>  struct b bb[512];
>>>>  int c;
>>>>  }PCI;
>>>>it's normal.
>>>>please tell me why?
>>>>thanks a lot.
>>>>
>

-- 
===================Liu duo
tel:(010)62570007-509
email:liuduo@sinosoft.com.cn
Sinosoft Software.Co.Ltd.
Esmpro Group.Secic Department
===================


