From: liuduo <liuduo@sinosoft.com.cn>
Date: Fri, 16 Jan 2004 03:56:24 +0000
Subject: a question about memory access on IA64
Message-Id: <4007623A.50101@sinosoft.com.cn>
List-Id: <linux-ia64.vger.kernel.org>
References: <40075464.6010202@sinosoft.com.cn>
In-Reply-To: <40075464.6010202@sinosoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David:
Sorry, i only describe the process about the error occurs .

    typedef struct b{
      char*  pDescriptName;
      char*           pVendorName;
      unsigned int	RevisionID;
     }B;

    typedef struct pci{
     int c;
     struct b bb[512];
     }PCI;

int main()
{


     struct pci a;

     //function for operation a
     func(&a);
     return 0;
}
the func is in an lib, it's an lib export function, and the func is as 
follows;

func(struct pci* a)
{
      char tmp[256];
     for(num=0;num<512;num++)
     {
      a->bb[num].pDescriptName = (char*)malloc(100);
      strcpy(a->bb[num].pDescriptName , "dddd");
      a->bb[num].pVendorName = (char*)malloc(100);
      strcpy(a->bb[num].pVendorName , "fffff");
      a->bb[num].RevisionID = 22;
     }
     a->c = 512;
}
when call the func , the segmentation fault occurs,
and then we modified the struct A as follows
     typedef struct pci{
     struct b bb[512];
     int c;
     }PCI;
it's normal.
please tell me why?
thanks a lot.
-- 
===================Liu duo
tel:(010)62570007-509
email:liuduo@sinosoft.com.cn
Sinosoft Software.Co.Ltd.
Esmpro Group.Secic Department
===================


