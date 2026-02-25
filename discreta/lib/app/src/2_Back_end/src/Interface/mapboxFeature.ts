import { MapboxContext } from "./mapboxContext";

export interface MapboxFeature {
  place_name: string;
  text: string;
  context?: MapboxContext[];
}
