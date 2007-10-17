package gov.usgswim.sparrow.test;


import junit.framework.Test;
import junit.framework.TestSuite;

public class _OfflineTest {
	public static Test suite() {
		TestSuite suite;
		suite = new TestSuite("Prediction Tests");
		
		

		suite.addTestSuite(PredictSimple_Test.class);
	  suite.addTestSuite(TabDelimFileUtil_Test.class);
		suite.addTestSuite(Int2D_Test.class);
		suite.addTestSuite(Double2D_Test.class);
	  suite.addTestSuite(Data2DView_Test.class);
		suite.addTestSuite(Data2DBuilder_Test.class);
		//suite.addTestSuite(JDBCUtil_Test.class);
		suite.addTestSuite(SourceAdjustments_Test.class);
		//suite.addTestSuite(DomainSerializerTest.class);
		suite.addTestSuite(PredictSerializerTest.class);
		
		//suite.addTestSuite(ModelServiceTest.class);
		//suite.addTestSuite(PredictServiceTest.class);
	  
		return suite;
	}

	public static void main(String args[]) {
		String args2[] = {"-noloading", "gov.usgswim.sparrow.test._Test"};

		junit.swingui.TestRunner.main(args2);
	}
}