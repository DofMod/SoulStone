SoulStone
=========

By ExiTeD and Relena

Download + Compile:
-------------------

1. Install Git
2. git clone --recursive https://github.com/alucas/SmithMagic.git
3. cd SmithMagic/dmUtils/
4. Compile dmUtils library (see README)
5. cd ..
6. mxmlc -output SmithMagic.swf -compiler.library-path+=./modules-library.swc -compiler.library-path+=dmUtils/dmUtils.swc -source-path src -keep-as3-metadata Api Module DevMode -- src/SmithMagic.as
