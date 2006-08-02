From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 02 Aug 2006 08:17:35 +0000
Subject: RSE and incomplete register frame
Message-Id: <44D05F9F.3070804@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi there,

for an IA64 related question I dropped a query to 
ia64-technical@gelato.unsw.edu.au . However there was not really any 
helpful response. So please let me make use of the bigger audience on 
this list. Your comments are all welcome. Thanks.

Here the original text:
Hi,

while developing an instruction set simulator I found the chapter about 
incomplete register frame (ASDM vol. 2) to be inaccurate. It says that 
the incomplete frame becomes complete when RSE.ndirty_words becomes 
non-negative by executing mandatory RSE loads. However, mandatory RSE 
loads are not touching BSPSTORE or the dirty partition. RSE loads are 
extending the clean partition. Furthermore if you consider RSE.BOF to 
end up inside the clean partition after a br.ret or rfi, then BSPSTORE 
is located above BSP. However, the new current frame should be 
considered complete since there are no mandatory RSE loads needed. Given 
this, BSPSTORE should be replaced by RSE.Bspload, which is the true 
criterion for an incomplete register frame.

The practice when dealing with br.ret or rfi seems to be that BSPSTORE 
is forced to BSP when RSE.BOF is updated into the clean partition. 
However, this behavior is lacking documentation in one of the ASDM.

Christian


____________
Virus checked by G DATA AntiVirusKit


