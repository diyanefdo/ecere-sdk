public import IMPORT_STATIC "ecere"

public define invalidTriangleVertex = 0xFFFFFFFF;

public struct BinaryTriangle
{
   BinaryTriangle * left, * right, * bottom;
   BinaryTriangle * leftTriangle, * rightTriangle;
   uint tv0, tva, tv1, tvc;
   int index;

   private static inline uint ::midPoint(int v0, int v1, int stride)
   {
      int y0 = v0 / stride, y1 = v1 / stride;
      return Abs(y0 - y1) >= 2 || Abs((v0 - y0 * stride) - (v1 - y1 * stride)) >= 2 ? ((v0 + v1) >> 1) : invalidTriangleVertex;
   }

   private void createChildTriangles(BinaryTriangle * stack, int * stackIndex, int stride)
   {
      BinaryTriangle * r = right, * l = left;
      BinaryTriangle * lt = stack + (*stackIndex)++;
      BinaryTriangle * rt = stack + (*stackIndex)++;

      leftTriangle = lt;
      rightTriangle = rt;

      if(l)
      {
         if(l->bottom == this)
            l->bottom = lt;
         else if(l->left == this)
            l->left = lt;
         else
            l->right = lt;
      }

      if(r)
      {
         if(r->bottom == this)
            r->bottom = rt;
         else if(r->right == this)
            r->right = rt;
         else
            r->left = rt;
      }

      *lt =
      {
         index = index << 1,
         left = rt, bottom = l,
         tv0 = tva, tva = tvc, tv1 = tv0,
         tvc = midPoint(tv0, tva, stride);
      };

      *rt =
      {
         index = (index << 1) + 1,
         right = lt, bottom = r,
         tv0 = tv1, tva = tvc, tv1 = tva,
         tvc = midPoint(tv1, tva, stride);
      };
   }

   public void clear()
   {
      leftTriangle = null;
      rightTriangle = null;
      left = null;
      right = null;
      bottom = null;
   }

   public bool split(BinaryTriangle * stack, int * stackIndex, int stride)
   {
      bool result = false;

      if(bottom)
      {
         // Opposite triangle needs to be split first to avoid T-junction
         if(bottom->tvc != invalidTriangleVertex && (bottom->bottom == this || bottom->split(stack, stackIndex, stride)))
         {
            BinaryTriangle * b, * blt, * brt;

            createChildTriangles(stack, stackIndex, stride);
            bottom->createChildTriangles(stack, stackIndex, stride);
            b = bottom;
            blt = b->leftTriangle;
            brt = b->rightTriangle;
            leftTriangle->right = brt;
            rightTriangle->left = blt;
            blt->right = rightTriangle;
            brt->left = leftTriangle;
            result = true;
         }
      }
      else
      {
         createChildTriangles(stack, stackIndex, stride);
         leftTriangle->right = null;
         rightTriangle->left = null;
         result = true;
      }
      return result;
   }
};
