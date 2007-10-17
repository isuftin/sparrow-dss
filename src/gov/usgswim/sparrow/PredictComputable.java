package gov.usgswim.sparrow;


import gov.usgswim.sparrow.service.SharedApplication;
import gov.usgswim.task.Computable;

import org.apache.log4j.Logger;

/**
 * Task to load create a prediction based on a PreditionRequest.
 * 
 * By implementing Computable, this task can be put in a ComputableCache, which
 * executes the task if the result does not already exist.
 */
public class PredictComputable implements Computable<PredictRequest, Double2DImm> {
	protected static Logger log =
		Logger.getLogger(PredictComputable.class); //logging for this class
		
		
	public PredictComputable() {
	}

	public Double2DImm compute(PredictRequest request) throws Exception {
		PredictData data = loadData(request);
		PredictData adjData = adjustData(request, data);
		
		long startTime = System.currentTimeMillis();

		Double2DImm result = runPrediction(request, adjData);
		
		log.debug(
			"Prediction done for model #" + request.getModelId() + 
			" Time: " + (System.currentTimeMillis() - startTime) + "ms, " +
			adjData.getSrc().getRowCount() + " reaches");
			
		return result;
	}
	
	/**
	 * Loads the model sources, coefs, and values needed to run the prediction.
	 * @param arg
	 * @return
	 */
	public PredictData loadData(PredictRequest req) throws Exception {
		return SharedApplication.getInstance().getPredictDatasetCache().compute( req.getModelId() );
	}
	
	/**
	 * Adjusts the passed data based on the adjustments in the requests.
	 *
	 * It is assumed that the passed data is immutable, in which case a mutable
	 * builder is created, adjusted, copied as immutable, and returned.
	 * 
	 * If the passed data is mutable (an instance of PredictionDataBuilder,
	 * possibly for testing purposes), it will be adjusted by setting a new source,
	 * copied as immutable, and returned.
	 * 
	 * If there are no adjustments, the passed dataset is returned.
	 *
	 * @param req
	 * @param data
	 * @return
	 */
	public PredictData adjustData(PredictRequest req,
																			PredictData data) throws Exception {
		
		if (req.getAdjustmentSet().hasAdjustments()) {
			PredictDataBuilder mutable = data.getBuilder();

			
			//This method does not modify the underlying data
			mutable.setSrc(
					req.getAdjustmentSet().adjust(mutable.getSrc(), mutable.getSrcIds(), mutable.getSys())
			);
			
			return mutable.getImmutable();
		}
		
		return data;
	}
	
	/**
	 * Runs the actual prediction using the passed base data.
	 *
	 * The passed data is not modified.
	 *
	 * @param arg
	 * @param data
	 * @return
	 */
	public Double2DImm runPrediction(PredictRequest req,
																PredictData data) {
		PredictRunner adjPredict = new PredictRunner(data);
		return adjPredict.doPredict();
	}
}