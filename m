From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 16 Jan 2004 04:59:56 +0000
Subject: Re: a question about memory access on IA64
Message-Id: <16391.28620.39161.362377@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40075464.6010202@sinosoft.com.cn>
In-Reply-To: <40075464.6010202@sinosoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sorry, but your problem report is still very incomplete.  Please
provide a _self-contained_ minimal test program that reproduces the
problem for you and describe you how compile the program.  Without a
complete test-case there are a million variations of what could be
wrong.

	--david

>>>>> On Fri, 16 Jan 2004 12:02:02 +0800, liuduo <liuduo@sinosoft.com.cn> said:

  Liuduo> David:
  Liuduo> Sorry, i only describe the process about the error occurs .

  Liuduo> typedef struct b{
  Liuduo> char*  pDescriptName;
  Liuduo> char*           pVendorName;
  Liuduo> unsigned int	RevisionID;
  Liuduo> }B;

  Liuduo> typedef struct pci{
  Liuduo> int c;
  Liuduo> struct b bb[512];
  Liuduo> }PCI;

  Liuduo> int main()
  Liuduo> {


  Liuduo> struct pci a;

  Liuduo> //function for operation a
  Liuduo> func(&a);
  Liuduo> return 0;
  Liuduo> }
  Liuduo> the func is in an lib, it's an lib export function, and the func is as 
  Liuduo> follows;

  Liuduo> func(struct pci* a)
  Liuduo> {
  Liuduo> char tmp[256];
  Liuduo> for(num=0;num<512;num++)
  Liuduo> {
  a-> bb[num].pDescriptName = (char*)malloc(100);
  Liuduo> strcpy(a->bb[num].pDescriptName , "dddd");
  a-> bb[num].pVendorName = (char*)malloc(100);
  Liuduo> strcpy(a->bb[num].pVendorName , "fffff");
  a-> bb[num].RevisionID = 22;
  Liuduo> }
  a-> c = 512;
  Liuduo> }
  Liuduo> when call the func , the segmentation fault occurs,
  Liuduo> and then we modified the struct A as follows
  Liuduo> typedef struct pci{
  Liuduo> struct b bb[512];
  Liuduo> int c;
  Liuduo> }PCI;
  Liuduo> it's normal.
  Liuduo> please tell me why?
  Liuduo> thanks a lot.
  Liuduo> -- 
  Liuduo> ===================  Liuduo> Liu duo
  Liuduo> tel:(010)62570007-509
  Liuduo> email:liuduo@sinosoft.com.cn
  Liuduo> Sinosoft Software.Co.Ltd.
  Liuduo> Esmpro Group.Secic Department
  Liuduo> ===================

